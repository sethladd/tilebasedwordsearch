library persistable;

import 'dart:async';
import 'dart:mirrors';

Future init(String url) {
  return new Future.value(true);
}

abstract class Persistable {
  
  int _dbId;
  
  static Future load(int id, Type type) {
    throw new UnimplementedError();
  }
  
  Future store() {
    throw new UnimplementedError();
  }
  
  // This assumes there's no reason for code to change an ID.
  int get dbId => _dbId;
}
