library persistable;

import 'dart:async';
import 'dart:mirrors';
import 'package:logging/logging.dart';
import 'package:postgresql/postgresql.dart';  // XXX This pulls in dart:io

Logger _log = new Logger('persistable');

Connection _conn;

Future init(String url) {
  return connect(url).then((conn) {
    _conn = conn;
    return true;
  });
}

abstract class Persistable {
  static Map<Type, List<String>> _columnNames = new Map<Type, List<String>>();
  
  int dbId;
  
  static const constructor = const Symbol('fromPersistance');
  
  static Future load(int id, Type type) {
    var query = 'SELECT * FROM ${_getTableName(type)} WHERE id = @id';
    
    return _conn.query(query, {'id': id}).map((r) => _rowToMap(r)).toList().then((List rows) {
      if (rows.isEmpty) return null; // TODO: throw if empty?
      
      var data = _rowToMap(rows.first);
      var classMirror = reflectClass(type);
      return _createAndPopulate(classMirror, id, data);
    });
  }
  
  static Stream findBy(Type type, Map params) {
    _validateParams(type, params);
    
    var classMirror = reflectClass(type);
    var conditions = params.keys.map((k) => '$k = @${k}').join(',');
    var query = 'SELECT * FROM ${_getTableName(type)} WHERE $conditions';
    
    _log.fine('Query $query');
    
    return _conn.query(query, params).map((row) {
      return _createAndPopulate(classMirror, row.id, _rowToMap(row));
    });
  }
  
  static Future _validateParams(Type type, Map params) {
    return _getColumns(type).then((List<String> columns) {
      params.keys.forEach((k) {
        if (!columns.contains(k)) {
          throw '$k is not a known column for $type';
        }
      });
    });

  }
  
  static _createAndPopulate(ClassMirror classMirror, int id, Map data) {
    var instance = classMirror.newInstance(const Symbol(''), []);
    var object = instance.reflectee;
    object.dbId = id;
    var instanceMirror = reflect(object);
    data.forEach((k, v) {
      _log.fine('$k has $v which is a ${v.runtimeType}');
      if (classMirror.variables.containsKey(new Symbol(k))) {
        instanceMirror.setField(new Symbol(k), v);
      }
    });
    return object;
  }
  
  Future store() {
    _log.info('inside store');
    
    if (dbId == null) {
      return _doInsert();
    } else {
      return _doUpdate();
    }
  }

  Future _doInsert() {
    _log.info('inserting');
    
    return _getColumns(runtimeType).then((cols) {
        var map = _getExistingValues(cols);
  
        var query = 'INSERT INTO $_tableName (${map.keys.join(',')}) VALUES '
                    '(${map.keys.map((c) => '@$c').join(',')}) '
                    'returning id';
                    
        _log.fine('Query: $query');
                    
        return _conn.query(query, map).first.then((row) {
          _log.fine('Result after inserting: $row');
          dbId = row[0];
        });
      });
  }

  Future _doUpdate() {
    return _getColumns(runtimeType).then((cols) {
        var map = _getExistingValues(cols);
        map['id'] = dbId;
        
        var query = 'UPDATE $_tableName SET '
            '${map.keys.map((c) => '$c = @$c').join(', ')} '
            'WHERE id = @id';
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
  
  static Future<List<String>> _getColumns(Type type) {
    if (_columnNames[type] != null) return new Future.value(_columnNames[type]);
    
    final sql = '''
      SELECT a.attname
        FROM pg_attribute a LEFT JOIN pg_attrdef d
          ON a.attrelid = d.adrelid AND a.attnum = d.adnum
       WHERE a.attrelid = '${_getTableName(type)}'::regclass
         AND a.attnum > 0 AND NOT a.attisdropped
       ORDER BY a.attnum
    ''';
    
    return _conn.query(sql).toList().then((rows) {
      _columnNames[type] = rows.map((row) => row.attname).toList();
      return _columnNames[type];
    });
  }
  
  static String _getTableName(Type type) => type.toString().toLowerCase();
  
  String get _tableName => _getTableName(runtimeType);

  Map toJson();
}

Map _rowToMap(row) {
  var map = {};
  row.forEach((String name, value) => map[name] = value);
  return map;
}
