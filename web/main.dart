import 'dart:html';
import 'dart:async';
import 'dart:json';
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
  var ppanel = query('.primary');
  
  if (ppanel != null) {
    bool headIntoSunset = window.innerWidth > 500;
    var delay = headIntoSunset? 4:1; // # of seconds before tada

    // Move or disappear the image.
    if (headIntoSunset) {
      ppanel.style.transition = 'all 4s ease-in';
      ppanel.style.backgroundPositionX = '-150%';
    } else {
      ppanel.style.transition = 'all 0.5s';
      ppanel.style.backgroundSize = "0px 0px";
    }
    
    // Remove the transition and image.
    new Timer(new Duration(seconds:delay), () {
      ppanel.style.transition = 'none 0s ease';
      ppanel.style.backgroundImage = 'none';
      // PENDING: should I clean up more?

      var mpanel = query('.main-panel');
      if (mpanel != null) {
        mpanel.style.backgroundImage = "url('../assets/WordHerder.png')";
      }
    });
  }
}

/**
 * Request the anti-request forgery state token. 
 */
_requestSessionToken() {
  HttpRequest.getString("/session")
  .then((data) {
    var stateTokenData = parse(data);
    var meta = new MetaElement()
    ..name = "state_token"
    ..content = stateTokenData["state_token"];
    
    document.head.children.add(meta);
  })
  .catchError((error) {
    Logger.root.fine("Requesting Session Token Failed: $error");
  });
}

main() {
  _removeLoadingAnimation();
  _setupLogger();
  _requestSessionToken();
  app.initialize();
}