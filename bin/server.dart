library hello_static;

import "package:start/start.dart";
import 'package:postgresql/postgresql.dart';
import 'dart:io';

Connection db;

void main() {
  var port = int.parse(Platform.environment['PORT'], onError: (_) => 8080);
  var dbUrl;
  if (Platform.environment['DATABASE_URL'] != null) {
    dbUrl = Platform.environment['DATABASE_URL'];
  } else {
    var user = Platform.environment['USER'];
    dbUrl = 'postgres://$user:@localhost:5432/$user';
  }
  
  connect(dbUrl)
  .then((conn) => db = conn)
  .then((_) {
    print('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      print('HTTP server started');
      app.get('/games/:id', getGame);
      //app.get('/games/mine', myGames);
    });
  })
  .catchError((e) => print("error: $e"));
}

getGame(Request req, Response res) {
  var id = req.params['id'];
  db.query('SELECT * FROM games WHERE id = @id', {'id': id}).first.then((game) {
    res.json(game);
  });
}

//createCat(Request req, Response res) {
//  HttpBodyHandler.processRequest(req.input)
//    .then((HttpBody body) {
//      return body.body['name'];
//    })
//    .then((name) => db.execute('INSERT INTO cats (name) VALUES (@n)', {'n':name}))
//    .then((_) {
//      res
//       ..status(201)
//       ..close();
//    })
//    .catchError((e) {
//      print("Error with insert: $e");
//      res
//        ..status(500)
//        ..close();
//    });
//}