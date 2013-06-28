import 'package:web_ui/component_build.dart';
import 'dart:io';
import 'dart:async';

void main() {
  Future task = build(new Options().arguments, ['web/index.html']);
  
  task
      .then((_) => Process.run('cp', ['-R', 'web/assets', 'web/favicon-32.png', 'web/out']))
      .then((_) => generateAppCache())
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
  out.writeln('\nCACHE:');
  
  new Directory('web/out')
      .listSync(recursive: true, followLinks: false)
      .forEach((entry) {
        if (entry is Link || entry.path.endsWith('.map') ||
            entry.path.contains('_from_packages') ||
            entry is Directory || entry.path.endsWith('appcache.manifest')) {
          return;
        }
        out.writeln(entry.path);
      });
  
  out.writeln('web/out/index.html_bootstrap.dart.js');
  out.writeln('packages/browser/dart.js');
  out.writeln('packages/browser/interop.js');
  out.writeln('packages/js/dart_interop.js');
  
  out.writeln('\nNETWORK:');
  out.writeln('*');
  out.close();
}
