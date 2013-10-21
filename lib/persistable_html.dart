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


/**
 * XXX We don't use this when we compile to dart2js because
 * of code size generation. There is a fix coming:
 * https://code.google.com/p/dart/issues/detail?id=10905
 */
abstract class Persistable {
  
  String id;
  
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
      return _createAndPopulate(classMirror, data['id'], data);
    });
  }
  
  Future store() {
    if (id == null) {
      id = _nextId();
    }
    return _store.save(toJson(), id);
  }
  
  Future delete() {
    return _store.removeByKey(id);
  }
  
  static Future clear() {
    return _store.nuke();
  }
  
  static _createAndPopulate(ClassMirror classMirror, String id, Map data) {
    var instance = classMirror.newInstance(const Symbol(''), []);
    Persistable object = instance.reflectee;
    object.id = id;
    var instanceMirror = reflect(object);
    data.forEach((k, v) {
      log.fine('$k has $v which is a ${v.runtimeType}');
      if (classMirror.variables.containsKey(new Symbol(k))) {
        instanceMirror.setField(new Symbol(k), v);
      }
    });
    return object;
  }
  
  String _nextId() => _idOffset + '-' + (_counter++).toString();

}