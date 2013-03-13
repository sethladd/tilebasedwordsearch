import 'package:unittest/unittest.dart';
import 'package:tilebasedwordsearch/dictionary.dart';

main() {
  var dict = new Dictionary.fromFile("AA\nBB\nCC");
  test('has three words', () {
    expect(dict.length, equals(3));
  });
  
  test('has AA', () {
    expect(dict.hasWord('AA'), equals(true));
  });
  
  test('does not have QQ', () {
    expect(dict.hasWord('QQ'), equals(false));
  });
}

