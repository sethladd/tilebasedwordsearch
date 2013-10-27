#!/usr/bin/env dart

import 'package:polymer/builder.dart';

void main() {
  lint(entryPoints: ['web/index.html']);
}

//generateAppCache() {
//  var file = new File('web/out/appcache.manifest');
//  if (!file.existsSync()) {
//    file.createSync();
//  }
//  
//  IOSink out = file.openWrite();
//  out.writeln('CACHE MANIFEST');
//  out.writeln('# ${new DateTime.now()}');
//  out.writeln('\nCACHE:');
//  
//  new Directory('web/out')
//      .listSync(recursive: true, followLinks: false)
//      .forEach((entry) {
//        if (entry is Link || entry.path.endsWith('.map') ||
//            entry.path.contains('_from_packages') ||
//            entry is Directory || entry.path.endsWith('appcache.manifest')) {
//          return;
//        }
//        out.writeln(entry.path);
//      });
//  
//  out.writeln('web/out/index.html_bootstrap.dart.js');
//  out.writeln('packages/browser/dart.js');
//  out.writeln('packages/browser/interop.js');
//  out.writeln('packages/js/dart_interop.js');
//  
//  out.writeln('\nNETWORK:');
//  out.writeln('*');
//  out.close();
//}
