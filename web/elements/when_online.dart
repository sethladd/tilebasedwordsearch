import 'package:polymer/polymer.dart';  // XXX DO NOT USE SHOW HERE
import 'dart:html';

/**
 * TODO actually try to reach the server, which tests the network link.
 */
@CustomTag('when-online')
class WhenOnline extends PolymerElement {
  @observable bool isOnline = false;

  WhenOnline.created() : super.created();

  @override
  void enteredView() {
    super.enteredView();

    if (window.navigator.onLine) {
      isOnline = true;
    }

    window.onOnline.listen((_) => isOnline = true);
    window.onOffline.listen((_) => isOnline = false);
  }
}