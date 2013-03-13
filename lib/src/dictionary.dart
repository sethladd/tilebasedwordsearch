part of tilebasedwordsearch;

class Dictionary {
  final Map words = new Map();
  
  Dictionary.fromFile(String contents) {
    contents.split('\n').forEach((word) => words[word] = true);
  }
  
  bool hasWord(String word) => words.containsKey(word);
  
  int get length => words.length;
}

