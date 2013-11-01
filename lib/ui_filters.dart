library filters;

import 'package:polymer_expressions/filter.dart' show Transformer;

class StringToInt extends Transformer<String, int> {
  final int radix;
  StringToInt({this.radix: 10});
  String forward(int i) => '$i';
  int reverse(String s) => s == null ? null : int.parse(s, radix: radix, onError: (s) => null);
}