import 'package:web_ui/component_build.dart';
import 'dart:io';
import 'dart:async';

void main() {
  Future task = build(new Options().arguments, ['web/index.html']);
  
  task
      .then((_) => Process.run('cp', ['-R', 'web/assets', 'web/out']))
      .then((_) => print('All done'));
}

generateAppCache() {
  var file = new File('web/out/appcache.manifest');
  if (!file.existsSync()) {
    file.createSync();
  }
  
  IOSink out = file.openWrite();
  out.writeln('CACHE MANIFEST');
  out.writeln('# ${new DateTime.now()}');
  out.writeln('CACHE:');
  
  out.writeln('NETWORK:');
  out.writeln('*');
  out.close();
}