#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  build(entryPoints: ['web/index.html'])
  //.then((_) => deploy(entryPoints: ['web/index.html']))
  .then((_) {
    if (parseOptions().forceDeploy) {
      compileToJs();
    }
  });
}

compileToJs() {
  String dartCmd = new Options().executable;
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
