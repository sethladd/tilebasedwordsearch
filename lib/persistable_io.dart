library persistable;

import 'dart:async';
import 'dart:mirrors';
import 'dart:convert' show JSON;
import 'package:logging/logging.dart';
import 'package:serialization/serialization.dart';
import 'package:postgresql/postgresql.dart';  // XXX This pulls in dart:io

Logger _log = new Logger('persistable');

Connection _conn;

Future init(String url) {
  return connect(url).then((conn) {
    _conn = conn;
    return true;
  });
}

const String serialized = "__SERIALIZED";

final Serialization _serialization = new Serialization();

abstract class Persistable {
  static Map<Type, List<String>> _columnNames = new Map<Type, List<String>>();
  
  String id;
  
  static const constructor = const Symbol('fromPersistance');
  
  static Future load(String id, Type type) {
    var query = 'SELECT * FROM ${_getTableName(type)} WHERE id = @id';
    
    return _conn.query(query, {'id': id}).map((r) => _rowToMap(r)).toList().then((List rows) {
      if (rows.isEmpty) throw 'No $type found for ID $id';
      
      var data = _rowToMap(rows.first);
      var classMirror = reflectClass(type);
      return _createAndPopulate(classMirror, id, data);
    });
  }
  
  static Stream findByWhere(Type type, String whereClause, Map params) {
    _validateParams(type, params);
    String query = 'SELECT * FROM ${_getTableName(type)} WHERE $whereClause';
    ClassMirror classMirror = reflectClass(type);
    
    return _conn.query(query, params).map((row) {
      return _createAndPopulate(classMirror, row.id, _rowToMap(row));
    });
  }
  
  static Stream all(Type type) {
    _log.fine('Inside all');
    
    String query = 'SELECT * FROM ${_getTableName(type)}';
    ClassMirror classMirror = reflectClass(type);
    
    return _conn.query(query).map((row) {
      return _createAndPopulate(classMirror, row.id.toString(), _rowToMap(row));
    });
  }
  
  static Stream findBy(Type type, Map params) {
    _validateParams(type, params);
    Map conditionValues = new Map.from(params);
    
    ClassMirror classMirror = reflectClass(type);
    String conditions = params.keys.map((k) {
      String condition = '$k ';
      if (params[k] is List) {
        List list = params[k];
        int i = 0;
        
        condition += ' IN (';
        condition += list.map((e) => '@${k}_${i++}').join(',');
            
        for (var j = 0; j < i; j++) {
          conditionValues['${k}_$j'] = list[j];
        }
        
        condition += ')';
      } else {
        condition += ' = @$k';
      }
      return condition;
    }).join(',');
    
    String query = 'SELECT * FROM ${_getTableName(type)} WHERE $conditions';
    
    //_log.fine('Query $query ; conditions $conditionValues');
    
    return _conn.query(query, conditionValues).map((row) {
      return _createAndPopulate(classMirror, row.id, _rowToMap(row));
    });
  }
  
  /**
   * Completes with [null] if no record was found.
   */
  static Future findOneBy(Type type, Map params) {
    return findBy(type, params).toList().then((List list) {
      return (list.isEmpty ? null : list[0]);
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
  
  static _createAndPopulate(ClassMirror classMirror, String id, Map data) {
    var instance = classMirror.newInstance(const Symbol(''), []);
    Serialization ser = new Serialization()..addRuleFor(instance);
    Persistable object = instance.reflectee;
    object.id = id;
    var instanceMirror = reflect(object);
    data.forEach((k, v) {
      Symbol fieldName = new Symbol(k);
      //_log.fine('$k has $v which is a ${v.runtimeType}');
      if (classMirror.variables.containsKey(fieldName)) {
        VariableMirror field = classMirror.variables[fieldName];
        if (isFieldSerialized(field)) {
          v = _serialization.read(JSON.decode(v));
        }
        instanceMirror.setField(fieldName, v);
      }
    });
    return object;
  }

  static bool isFieldSerialized(VariableMirror field) {
    return field.metadata.any((InstanceMirror im) => im.reflectee == serialized);
  }
  
  Future store() {
    _log.info('inside store');
    
    if (id == null) {
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
          id = row[0].toString();
        });
      });
  }

  Future _doUpdate() {
    return _getColumns(runtimeType).then((cols) {
        var map = _getExistingValues(cols);
        map['id'] = id;
        
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
          VariableMirror field = classMirror.variables[c];
          if (isFieldSerialized(field)) {
            map[MirrorSystem.getName(c)] = JSON.encode(_serialization.write(mirror.getField(c).reflectee));
          } else {
            map[MirrorSystem.getName(c)] = mirror.getField(c).reflectee;
          }
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

  //Map toJson();
}

Map _rowToMap(row) {
  var map = {};
  row.forEach((String name, value) => map[name] = value);
  return map;
}