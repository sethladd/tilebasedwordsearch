import 'package:unittest/unittest.dart';
import 'package:tilebasedwordsearch/dictionary.dart';

main() {
  var dict = new Dictionary.fromFile("AA\nBB\nCC");
  test('has three words', () {
    expect(dict.length, equals(3));
  });
}

