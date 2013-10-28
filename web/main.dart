import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

main() {
  initLogging();
  initPolymer();
}

initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord logRecord) {
    StringBuffer sb = new StringBuffer()
      ..write(logRecord.time.toString())..write(":")
      ..write(logRecord.loggerName)..write(":")
      ..write(logRecord.level.name)..write(":")
      ..write(logRecord.sequenceNumber)..write(": ")
      ..write(logRecord.message.toString());
    print(sb.toString());
  });
}