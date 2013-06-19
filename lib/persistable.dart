library persistable;

import 'dart:async';
import 'dart:mirrors';
import 'package:logging/logging.dart';
//import 'package:postgresql/postgresql.dart';  XXX This pulls in dart:io

Logger log = new Logger('persistable');

Connection _conn;

Future init(String url) {
  return connect(url).then((conn) {
    _conn = conn;
    return true;
  });
}

abstract class Persistable {
  List _columnNames;
  
  int _dbId;
  
  static const constructor = const Symbol('fromPersistance');
  
  static Future load(int id, Type type) {
    var query = 'SELECT * FROM ${_getTableName(type)} WHERE id = @id';
    
    return _conn.query(query, {'id': id}).map((r) => _rowToMap(r)).toList().then((List rows) {
      if (rows.isEmpty) return null; // TODO: throw if empty?
      
      var row = rows.first;
      ClassMirror classMirror = reflectClass(type);
      
      // See dartbug.com/11161
      if (classMirror.constructors[new Symbol('$type.fromPersistance')] == null) {
        throw '$type should have a constructor $constructor';
      }
      
      var instance = classMirror.newInstance(constructor, [row]);
      var object = instance.reflectee;
      
      // Mixins can't have constructors, so I set the ID here.
      // Not sure if there's a better way.
      object._dbId = row['id'];
      
      return object;
    });
  }
  
  Future store() {
    log.info('inside store');
    
    if (dbId == null) {
      return _doInsert();
    } else {
      return _doUpdate();
    }
  }

  Future _doInsert() {
    log.info('inserting');
    
    return _columns.then((cols) {
        var map = _getExistingValues(cols);
  
        var query = 'INSERT INTO $_tableName (${map.keys.join(',')}) VALUES '
                    '(${map.keys.map((c) => '@$c').join(',')})';
                    
         return _transaction(() {
           log.info('in txn, executing $query');
          
           return _conn.execute(query, map)
             .then((_) {
               log.info('insert sql success');
               return _conn.query('SELECT max(id) FROM $_tableName').toList();
             })
             .then((List rows) {
               if (rows.isEmpty) {
                 throw 'Did not find max(id)';
               }
               log.info('Max ID is ${rows.first[0]}'); // make rows.first['id'] here, and try to debug it
               _dbId = rows.first[0];
             });
         }, 'insert');
      });
  }

  Future _doUpdate() {
    return _columns.then((cols) {
        var map = _getExistingValues(cols);
        map['id'] = dbId;
        
        var query = 'UPDATE $_tableName SET '
            '${map.keys.map((c) => '$c = @$c').join(', ')} '
            'WHERE id = @id';
        print(query);
        print(map);
        return _conn.execute(query, map);
      });
  }
  
  Map<String, dynamic> _getExistingValues(cols) {
    var mirror = reflect(this);
    var classMirror = reflectClass(runtimeType);
    var map = {};
    cols.map((c) => new Symbol(c))
        .where((c) => classMirror.variables.keys.contains(c))
        .forEach((Symbol c) {
          map[MirrorSystem.getName(c)] = mirror.getField(c).reflectee;
        });
    return map;
  }
  
  Future get _columns {
    if (_columnNames != null) return new Future.value(_columnNames);
    
    final sql = '''
      SELECT a.attname
        FROM pg_attribute a LEFT JOIN pg_attrdef d
          ON a.attrelid = d.adrelid AND a.attnum = d.adnum
       WHERE a.attrelid = '${_tableName}'::regclass
         AND a.attnum > 0 AND NOT a.attisdropped
       ORDER BY a.attnum
    ''';
    
    return _conn.query(sql).toList().then((rows) {
      _columnNames = rows.map((row) => row.attname).toList();
      return _columnNames;
    });
  }
  
  static String _getTableName(Type type) => type.toString().toLowerCase();
  
  String get _tableName => _getTableName(runtimeType);
  
  /**
   * Updates the object. The types of the values must match the
   * type annotations used on the class, if you want this to run in
   * checked mode.
   */
  void update(Map attributes) {
    final mirror = reflect(this);
    final classMirror = reflectClass(runtimeType);
    attributes.forEach((k, v) {
      if (classMirror.variables.containsKey(new Symbol(k))) {
        mirror.setField(new Symbol(k), v);
      }
    });
  }
  
  // This assumes there's no reason for code to change an ID.
  int get dbId => _dbId;
}

Future _transaction(Future inside(), [String logStmt = 'txn']) {
  logStmt = logStmt == null ? 'txn' : logStmt;
  return _conn.execute('BEGIN')
      .then((_) => inside())
      .then((_) => _conn.execute('COMMIT'))
      .catchError((e) {
        log.severe('Error with $logStmt: $e');
        return _conn.execute('ROLLBACK').then((_) => new Future.error(e));
      });
}

Map _rowToMap(row) {
  var map = {};
  row.forEach((String name, value) => map[name] = value);
  return map;
}
