library persistable_html;

import 'dart:async';
import 'package:lawndart/lawndart.dart';
import 'package:logging/logging.dart';

final Logger log = new Logger("persistence");

final Map<Type, Store> _stores = new Map<Type, Store>();

Future init(String dbName, Type type) {
  Store store = new Store(dbName, type.toString());
  _stores[type] = store;
  return store.open();
}

int _counter = 0;
final String _idOffset = new DateTime.now().millisecondsSinceEpoch.toString();

typedef Persistable Constructor(String id, Map data);

/**
 * See also the mirror-based implementation at persistable_html_mirrors.dart
 */
abstract class Persistable {
  
  String _id;
  
  /**
   * 
   */
  static Future load(String id, Type type, Constructor constructor) {
    Store store = _getStore(type);
    
    return store.getByKey(id).then((Map data) {
      if (data == null) {
        return null;
      } else {
        return _createAndPopulate(constructor, id, data);
      }
    });
  }
  
  static Stream all(Type type, Constructor constructor) {
    Store store = _getStore(type);
    
    return store.all().map((Map data) {
      return _createAndPopulate(constructor, data['id'], data);
    });
  }
  
  static Store _getStore(Type type) {
    Store store = _stores[type];
    if (store == null) {
      throw new StateError('No store for $type found. You have to init() first');
    }
    return store;
  }
  
  Future store() {
    Store store = _getStore(runtimeType);
    return store.save(toJson(), id);
  }
  
  Future delete() {
    Store store = _getStore(runtimeType);
    return store.removeByKey(id);
  }
  
  static Future clear() {
    Store store = _getStore(runtimeType);
    return store.nuke();
  }
  
  static _createAndPopulate(Constructor constructor, String id, Map data) {
    Persistable object = constructor(id, data);
    return object;
  }
  
  // This assumes there's no reason for code to change an ID.
  String get id {
    if (_id == null) {
      _id = _idOffset + '-' + (_counter++).toString();
    }
    return _id;
  }
  
  void set id(String id) { _id = id; }
  
  Map toJson();
}
