#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  build(entryPoints: ['web/index.html'], options: parseOptions(args))
  //.then((_) => deploy(entryPoints: ['web/index.html']))
  .then((_) {
    if (parseOptions(args).forceDeploy) {
      compileToJs();
      activateAndUpdateAppCache();
    }
  });
}

compileToJs() {
  String dartCmd = Platform.executable;
  String pathToCmd = path.dirname(dartCmd);
  String dart2jsCmd = pathToCmd == '.' ? 'dart2js' : path.join(path.dirname(dartCmd), 'dart2js');
  print('Running dart2js with path: $dart2jsCmd');
  var result =
    Process.runSync(dart2jsCmd, [
        '--minify',
        '-o', 'out/web/index.html_bootstrap.dart.js',
        'out/web/index.html_bootstrap.dart', '--suppress-hints'],
        runInShell: true);
  print("STDOUT: ${result.stdout}");
  print("STDERR: ${result.stderr}");
  print("Done compiling to JS");
}

activateAndUpdateAppCache() {
  activateAppCache();
  updateAppCache();
}

activateAppCache() {
  _replaceInFile('<html>',
                 '<html manifest="appcache.manifest">',
                 'out/web/index.html');
}

updateAppCache() {
  _replaceInFile('# DATETIME XXX',
                 '# DATETIME ${new DateTime.now()}',
                 'out/web/appcache.manifest');
}

_replaceInFile(final String placeholder, final String newText, final String filename) {
  File file = new File(filename);
  String fileContents = file.readAsStringSync();
  if (!fileContents.contains(placeholder)) {
    print("WARNING! Text '$placeholder' was not found: $filename");
    return;
  }
  fileContents = fileContents.replaceFirst(placeholder, newText);
  file.writeAsStringSync(fileContents, mode: FileMode.WRITE);
  print("$filename is updated");
}