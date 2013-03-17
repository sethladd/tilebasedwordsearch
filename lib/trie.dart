library trie;

import 'dart:collection';

class Trie<T> {
  T value;
  final Map<int, Trie<T>> map;

  Trie() : map = new Map<int, Trie<T>>();

  T operator [](String key) {
    var node = this;
    for (int i = 0; i < key.length; i++) {
      int char = key.codeUnitAt(i);

      node = node.map[char];
      if (node == null) {
        return null;
      }
    }
    return node.value;
  }
  
  Trie<T> nodeFor(String character) {
    return map[character.codeUnitAt(0)];
  }

  void operator []=(String key, T value) {
    var node = this;
    for (int i = 0; i < key.length; i++) {
      int char = key.codeUnitAt(i);

      var current = node;
      node = node.map[char];
      if (node == null) {
        current.map[char] = node = new Trie<T>();
      }
    }
    node.value = value;
  }

  void _collectValues(String prefix, Trie<T> node, Map<String, T> result) {
    if (node.value != null) {
      result[prefix] = node.value;
    }

    var keys = new List.from(node.map.keys);
    keys.sort( (a, b) => a - b );
    for (var char in keys) {
      var newPrefix = "$prefix${new String.fromCharCodes([char])}";
      _collectValues(newPrefix, node.map[char], result);
    }
  }

  Map<String, T> findByPrefix(String prefix) {
    var result = new LinkedHashMap<String, T>();

    var node = this;
    for (int i = 0; i < prefix.length; i+=1) {
      int char = prefix.codeUnitAt(i);

      node = node.map[char];
      if (node == null) {
        return result;
      }
    }

    _collectValues(prefix, node, result);
    return result;
  }
}

