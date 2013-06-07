import 'dart:html';

import "package:js/js.dart" as js;
import 'package:web_ui/web_ui.dart';
import 'package:tilebasedwordsearch/tilebasedwordsearch.dart' as app;

class LoginPanel extends WebComponent {
  void created() {
    /**
     * Calls the method that handles the authentication flow.
     *
     * @param {Object} authResult An Object which contains the access token and
     *   other authentication information.
     */
    js.scoped(() {
      js.context.onSignInCallback =  new js.Callback.many((js.Proxy authResult) {
        print("authResult = ${authResult}");
      });
    });

    var script = new ScriptElement();
    script.async = true;
    script.type = "text/javascript";
    script.src = "https://plus.google.com/js/client:plusone.js";
    document.body.children.add(script);
  }

}