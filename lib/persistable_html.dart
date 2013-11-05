library persistable_html;

import 'dart:async' show Future, Stream;
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

final Serialization _serializer = new Serialization();

abstract class Persistable {

  String id;

  static Future load(String id, Type type) {
    if (_store == null) throw new StateError('Store is not initialized');

    return _store.getByKey(id).then((String serialized) {
      if (serialized == null) {
        return null;
      } else {
        return _deserialize(serialized);
      }
    });
  }

  // TODO currently we assume all items in the store are of the same
  // type, so this doesn't so what you think it does. This selects
  // everything from the store and assumes its of type Type.
  static Stream all(Type type) {
    return _store.all().map((String serialized) => _deserialize(serialized));
  }

  static dynamic _deserialize(String serialized) {
    Map data = JSON.decode(serialized);
    return _serializer.read(data);
  }

  /**
   * Completes with the ID of the object just stored into persistence.
   */
  Future<String> store() {
    if (_store == null) throw new StateError('Store is not initialized');

    if (id == null) {
      id = _nextId();
    }

    // TODO do I need to encode to JSON? Can we store maps and lists of
    // core types?

    return _store.save(JSON.encode(_serializer.write(this)), id);
  }

  Future delete() {
    if (_store == null) throw new StateError('Store is not initialized');

    return _store.removeByKey(id);
  }

  static Future clear() {
    if (_store == null) throw new StateError('Store is not initialized');

    return _store.nuke();
  }

}
