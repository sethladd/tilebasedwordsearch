library persistable;

import 'dart:async';
import 'dart:mirrors';
import 'package:lawndart/lawndart.dart';

Store _store;

Future init(String dbName, String storeName) {
  _store = new Store('games', 'games');
  return _store.open();
}

int _counter = 0;

abstract class Persistable<T> {
  
  int _dbId;
  
  static Future load(int id, Type type) {
    throw new UnimplementedError();
  }
  
  static Future<List> all(Type type) {
    ClassMirror classMirror = reflectClass(type);

    return _store.all().toList().then((List<Map> data) {
      return data.map((Map r) {
        var instance = classMirror.newInstance(const Symbol(''), []);
        var object = instance.reflectee;
        object._update(r);
        return object;
      });
    });
  }
  
  /**
   * Updates the object. The types of the values must match the
   * type annotations used on the class, if you want this to run in
   * checked mode.
   */
  void _update(Map attributes) {
    final mirror = reflect(this);
    final classMirror = reflectClass(runtimeType);
    attributes.forEach((k, v) {
      if (classMirror.variables.containsKey(new Symbol(k))) {
        mirror.setField(new Symbol(k), v);
      }
    });
  }
  
  Future store() {
    return _store.save(toJson(), dbId);
  }
  
  Future delete() {
    return _store.removeByKey(dbId);
  }
  
  // This assumes there's no reason for code to change an ID.
  String get dbId {
    if (_dbId == null) {
      _dbId = _counter++;
    }
    
    return _dbId.toString();
  }
  
  dynamic toJson();
}
