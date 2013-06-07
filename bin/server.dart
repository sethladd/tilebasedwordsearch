library hello_static;

import "package:start/start.dart";
import 'package:postgresql/postgresql.dart';
import 'dart:io';

Connection db;

void main() {
  var port = int.parse(Platform.environment['PORT'], onError: (_) => 8080);
  var dbUrl = Platform.environment['DATABASE_URL'] != null ?
      Platform.environment['DATABASE_URL'] : 'postgres://sethladd:@localhost:5432/sethladd';
  
  connect(dbUrl)
  .then((conn) => db = conn)
  .then((_) {
    print('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      print('HTTP server started');
      app.post('/cats', createCat);
      app.get('/cats', listCats);
    });
  })
  .catchError((e) => print("error: $e"));
}

listCats(Request req, Response res) {
  db.query('SELECT * FROM cats').map((row) => row.name).toList().then((list) {
    res.json(list);
  });
}

createCat(Request req, Response res) {
  HttpBodyHandler.processRequest(req.input)
    .then((HttpBody body) {
      return body.body['name'];
    })
    .then((name) => db.execute('INSERT INTO cats (name) VALUES (@n)', {'n':name}))
    .then((_) {
      res
       ..status(201)
       ..close();
    })
    .catchError((e) {
      print("Error with insert: $e");
      res
        ..status(500)
        ..close();
    });
}