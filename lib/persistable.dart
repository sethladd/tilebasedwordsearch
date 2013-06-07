library persistable;

import 'dart:async';
import 'package:postgresql/postgresql.dart';

Connection _conn;

Future init(String url) {
  return connect(url).then((conn) {
    conn = _conn;
    return true;
  });
}

Future<Map> load(final String id, final String type) {
  if (_conn == null) {
    return new Future.error('Did not init DB first');
  }
  String tableName = type.toString().toLowerCase();
  return _conn.query('SELECT * FROM $tableName WHERE id = @id', {'id':id})
      .first;
}
