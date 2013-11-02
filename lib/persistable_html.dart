library persistable_html;

import 'dart:async' show Future, Stream;
import 'dart:mirrors' show ClassMirror, InstanceMirror, VariableMirror, reflectClass;
import 'package:lawndart/lawndart.dart' show Store;
import 'package:logging/logging.dart' show Logger;
import 'package:serialization/serialization.dart' show Serialization;
import 'dart:convert' show JSON;

final Logger log = new Logger("persistence");

const String serialized = "__SERIALIZED";

// TODO: one store per type
Store _store;

Future init(String dbName, String storeName) {
  _store = new Store(dbName, storeName);
  return _store.open();
}

int _counter = 0;
final String _idOffset = new DateTime.now().millisecondsSinceEpoch.toString();
String _nextId() => _idOffset + '-' + (_counter++).toString();

final Serialization _serialization = new Serialization();

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
    return _store.save(JSON.encode(_serialization.write(this)), id);
  }
  
  Future delete() {
    return _store.removeByKey(id);
  }
  
  static Future clear() {
    return _store.nuke();
  }
  
  static _createAndPopulate(ClassMirror classMirror, String id, Map data) {
    InstanceMirror instanceMirror = classMirror.newInstance(const Symbol(''), []);
    Persistable object = instanceMirror.reflectee;
    object.id = id.toString();
    data.forEach((k, v) {
      Symbol fieldName = new Symbol(k);
      if (classMirror.declarations.containsKey(fieldName) &&
          classMirror.declarations[fieldName] is VariableMirror) {
        VariableMirror field = classMirror.declarations[fieldName];
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

}