library log_handlers;

import 'package:logging/logging.dart';

onLogRecord(LogRecord logRecord) {
  StringBuffer sb = new StringBuffer()
    ..write(logRecord.time.toString())..write(":")
    ..write(logRecord.loggerName)..write(":")
    ..write(logRecord.level.name)..write(":")
    ..write(logRecord.sequenceNumber)..write(": ")
    ..write(logRecord.message.toString());

  if (logRecord.stackTrace != null) {
    sb
      ..write(' :\n')
      ..write(logRecord.stackTrace.toString());
  }

  print(sb.toString());
}