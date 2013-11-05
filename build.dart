#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

void main(List<String> _args) {
  ArgParser argsParser = _buildArgParser();
  ArgResults args = argsParser.parse(_args);

  if (args['help']) {
    _printHelp(argsParser);
    return;
  }

  CommandLineOptions options = _buildCommandLineOptions(args);

  build(entryPoints: ['web/index.html'], options: options)
  //.then((_) => deploy(entryPoints: ['web/index.html']))
  .then((_) {
    if (options.forceDeploy) {
      compileToJs(minify: args['minify']);

      if (args['appcache']) {
        print('Generating appcache');
        activateAndUpdateAppCache();
      } else {
        print('Skipping appcache generation');
      }
    }
  });
}

CommandLineOptions _buildCommandLineOptions(ArgResults res) {
  return new CommandLineOptions(res['changed'], res['removed'], res['clean'],
      res['full'], res['machine'], res['deploy'], res['out'], res['js'],
      res['csp']);
}

ArgParser _buildArgParser() {
  ArgParser argsParser = new ArgParser()
    ..addFlag('appcache', help: 'Generate the appcache', defaultsTo: true)
    ..addFlag('minify', help: 'Minifies the JS output', defaultsTo: true)

  // I don't know how to only parse for my options, because both the editor
  // and a human will run this script. I've copied out the params that
  // parseOptions requires

    ..addOption('changed', help: 'The file has changed since the last build.',
        allowMultiple: true)
    ..addOption('removed', help: 'The file was removed since the last build.',
        allowMultiple: true)
    ..addFlag('clean', negatable: false,
        help: 'Remove any build artifacts (if any).')
    ..addFlag('full', negatable: false, help: 'perform a full build')
    ..addFlag('machine', negatable: false,
        help: 'Produce warnings in a machine parseable format.')
    ..addFlag('deploy', negatable: false,
        help: 'Whether to force deploying.')
    ..addOption('out', abbr: 'o', help: 'Directory to generate files into.',
        defaultsTo: 'out')
    ..addFlag('js', help:
        'deploy replaces *.dart scripts with *.dart.js. This flag \n'
        'leaves "packages/browser/dart.js" to do the replacement at runtime.',
        defaultsTo: true)
    ..addFlag('csp', help:
        'replaces *.dart with *.dart.precompiled.js to comply with \n'
        'Content Security Policy restrictions.')
    ..addFlag('help', abbr: 'h',
        negatable: false, help: 'Displays this help and exit.');
  return argsParser;
}

_printHelp(ArgParser argsParser) {
  print('Wordherd-specific build options.');
  print(argsParser.getUsage());
  print('\n');
}

compileToJs({bool minify: true}) {
  String dartCmd = Platform.executable;
  String pathToCmd = path.dirname(dartCmd);
  String dart2jsCmd = pathToCmd == '.' ? 'dart2js' : path.join(path.dirname(dartCmd), 'dart2js');
  print('Running dart2js with path: $dart2jsCmd');
  var result =
    Process.runSync(dart2jsCmd, [
        minify ? '--minify' : '',
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