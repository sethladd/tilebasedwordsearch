import 'dart:html';
import 'dart:async';
import 'package:asset_pack/asset_pack.dart';
import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart' as app;
import 'package:logging/logging.dart';

void _setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord logRecord) {
    StringBuffer sb = new StringBuffer();
    sb
    ..write(logRecord.time.toString())..write(":")
    ..write(logRecord.loggerName)..write(":")
    ..write(logRecord.level.name)..write(":")
    ..write(logRecord.sequenceNumber)..write(": ")
    ..write(logRecord.message.toString());
    print(sb.toString());
  });
}

/* Animation gallops off to the left and then disappears. */
void _removeLoadingAnimation() {
  Element el = query('.primary');
  
  // Set up the transition.
  el.style.transition = 'all 4s ease-in';
  
  // Move the image.
  el.style.backgroundPositionX = '-150%';
  
  // Remove the transition and image.
  new Timer(new Duration(seconds:5), () {
    el.style.transition = 'none 0s ease';
    el.style.backgroundImage = 'none';
  });
}

main() {
  _removeLoadingAnimation();
  _setupLogger();
  app.initialize();
}
