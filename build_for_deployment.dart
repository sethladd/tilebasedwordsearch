#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';

void main() {
  lint(entryPoints: ['web/index.html'])
  .then((_) => deploy(entryPoints: ['web/index.html']))
  .then(compileToJs);
}

compileToJs(_) {
  print('Running dart2js, assuming it is on the PATH');
  var result =
    Process.runSync('dart2js', [
        //'--minify',
        '-o', 'out/web/index.html_bootstrap.dart.js',
        'out/web/index.html_bootstrap.dart', '--suppress-hints'],
        runInShell: true);
  print("STDOUT: ${result.stdout}");
  print("STDERR: ${result.stderr}");
  print("Done");
}
