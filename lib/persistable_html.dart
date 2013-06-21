library persistable_html;

import 'dart:async';
import 'dart:mirrors';
import 'package:lawndart/lawndart.dart';

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
        return _createAndPopulate(classMirror, data);
      }
    });
  }
  
  static Stream all(Type type) {
    ClassMirror classMirror = reflectClass(type);

    return _store.all().map((Map data) {
      return _createAndPopulate(classMirror, data);
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
  
  static _createAndPopulate(ClassMirror classMirror, Map data) {
    var instance = classMirror.newInstance(const Symbol(''), []);
    var object = instance.reflectee;
    var instanceMirror = reflect(object);
    data.forEach((k, v) {
      print('$k has $v which is a ${v.runtimeType}');
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
  
  Map toJson();
}
