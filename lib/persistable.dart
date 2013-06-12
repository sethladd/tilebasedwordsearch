library persistable;

import 'dart:async';
import 'dart:mirrors';
import 'package:logging/logging.dart';
import 'package:postgresql/postgresql.dart';

Logger log = new Logger('persistable');

Connection _conn;

Future init(String url) {
  return connect(url).then((conn) {
    _conn = conn;
    return true;
  });
}

abstract class Persistable {
  int _dbId;
  
  static const constructor = const Symbol('fromPersistance');
  
  static Future load(int id, Type type) {
    var query = 'SELECT * FROM ${_getTableName(type)} WHERE id = @id';
    
    return _conn.query(query, {'id': id}).map((r) => _rowToMap(r)).toList().then((List rows) {
      if (rows.isEmpty) return null;
      
      var row = rows.first;
      var classMirror = reflectClass(type);
      
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
    
    var map = toMap();
    List columns = map.keys.toList();
    columns.remove('id'); // TODO: make this better
    
    if (dbId == null) {
      log.info('inserting');
      
      var query = 'INSERT INTO $_tableName (${columns.join(',')}) VALUES '
                  '(${columns.map((c) => '@$c').join(',')})';
                  
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
       });

    } else {
      var query = 'UPDATE $_tableName SET '
                  '${columns.map((c) => '$c = @$c').join(',')} '
                  'WHERE id = @id';
      return _conn.execute(query, map);
    }
  }
  
  static String _getTableName(Type type) => type.toString().toLowerCase();
  
  String get _tableName => _getTableName(runtimeType);
  
  Map toMap();
  
  // This assumes there's no reason for code to change an ID.
  int get dbId => _dbId;
}

Future _transaction(Future inside()) {
  return _conn.execute('BEGIN')
      .then((_) => inside())
      .then((_) => _conn.execute('COMMIT'))
      .catchError((e) {
        log.severe('Error with insert: $e');
        return _conn.execute('ROLLBACK').then((_) => new Future.error(e));
      });
}

Map _rowToMap(row) {
  var map = <String, dynamic>{};
  row.forEach((String name, value) => map[name] = value);
  return map;
}
