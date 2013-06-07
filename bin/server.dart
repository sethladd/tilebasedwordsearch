library hello_static;

import "package:start/start.dart";
import 'package:tilebasedwordsearch/persistable.dart' as db;

import 'dart:io';

void main() {
  var port = Platform.environment['PORT'] != null ?
      int.parse(Platform.environment['PORT'], onError: (_) => 8080) :
      8080;
  
  var dbUrl;
  if (Platform.environment['DATABASE_URL'] != null) {
    dbUrl = Platform.environment['DATABASE_URL'];
  } else {
    var user = Platform.environment['USER'];
    dbUrl = 'postgres://$user:@localhost:5432/$user';
  }
  
  db.init(dbUrl)
  .then((_) {
    print('DB connected, now starting up web server');
    return start(public: 'web', host: '0.0.0.0', port: port).then((app) {
      print('HTTP server started');
      app.get('/games/:id').listen(getGame);
      app.post('/games').listen(createGame);
    });
  })
  .catchError((e) => print("error: $e"));
}

getGame(Request req) {
  var id = req.params['id'];
  db.load(id, 'game').then((Map row) {
    if (row == null) {
      req.response.status(HttpStatus.NOT_FOUND);
      req.response.close();
    } else {
      req.response.json(row);
    }
  });
}

createGame(Request req) {
  HttpBodyHandler.processRequest(req.input)
    .then((HttpBody body) {
      
    })
    .catchError((e) {
      req.response
          ..status(500)
          ..close();
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