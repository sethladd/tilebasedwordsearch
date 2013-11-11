import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart' show Level, Logger;
import 'package:wordherd/log_handlers.dart' show onLogRecord;

main() {
  initLogging();
  initPolymer();
}

initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(onLogRecord);
}