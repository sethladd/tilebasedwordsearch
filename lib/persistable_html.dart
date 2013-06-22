library persistable_html;

import 'dart:async';
import 'dart:mirrors';
import 'package:lawndart/lawndart.dart';
import 'package:logging/logging.dart';

final Logger log = new Logger("persistence");

// TODO: one store per type
Store _store;

Future init(String dbName, String storeName) {
  _store = new Store(dbName, storeName);
  return _store.open();
}

int _counter = 0;
final String _idOffset = new DateTime.now().millisecondsSinceEpoch.toString();

abstract class Persistable {
  
  String _dbId;
  
  static Future load(String id, Type type) {
    return _store.getByKey(id).then((Map data) {
      if (data == null) {
        return null;
      } else {
        var classMirror = reflectClass(type);
        return _createAndPopulate(classMirror, id, data);
      }
    });
  }
  
  static Stream all(Type type) {
    ClassMirror classMirror = reflectClass(type);

    return _store.all().map((Map data) {
      return _createAndPopulate(classMirror, data['dbId'], data);
    });
  }
  
  Future store() {
    return _store.save(toJson(), dbId);
  }
  
  Future delete() {
    return _store.removeByKey(dbId);
  }
  
  static Future clear() {
    return _store.nuke();
  }
  
  static _createAndPopulate(ClassMirror classMirror, String id, Map data) {
    var instance = classMirror.newInstance(const Symbol(''), []);
    var object = instance.reflectee;
    object.dbId = id;
    var instanceMirror = reflect(object);
    data.forEach((k, v) {
      log.fine('$k has $v which is a ${v.runtimeType}');
      if (classMirror.variables.containsKey(new Symbol(k))) {
        instanceMirror.setField(new Symbol(k), v);
      }
    });
    return object;
  }
  
  // This assumes there's no reason for code to change an ID.
  String get dbId {
    if (_dbId == null) {
      _dbId = _idOffset + '-' + (_counter++).toString();
    }
    return _dbId;
  }
  
  void set dbId(String id) { _dbId = id; }
  
  Map toJson();
}
