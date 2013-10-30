library filters;

import 'package:polymer/polymer.dart' show Polymer;
import 'package:polymer_expressions/filter.dart' show Transformer;
import 'package:polymer_expressions/polymer_expressions.dart' show PolymerExpressions;

class StringToInt extends Transformer<String, int> {
  final int radix;
  StringToInt({this.radix: 10});
  String forward(int i) => '$i';
  int reverse(String s) => s == null ? null : int.parse(s, radix: radix, onError: (s) => null);
}

// TODO this should be easier. See https://code.google.com/p/dart/issues/detail?id=14612
class PolymerExpressionsWithEventDelegate extends PolymerExpressions {
  PolymerExpressionsWithEventDelegate({Map globals}) : super(globals:globals);
  getBinding(model, String path, name, node) {
    return Polymer.getBindingWithEvents(
        model, path, name, node, super.getBinding);
  }
}