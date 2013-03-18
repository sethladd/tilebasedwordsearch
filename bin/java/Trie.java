import java.util.*;

public class Trie<T> {

    private T value;
    protected final Map<Character, Trie<T>> map;

    Trie() {
        this.map = new HashMap<Character, Trie<T>>();
    }
    
    public T getValue() {
        return value;
    }

    public T get(String key) {
        Trie<T> node = this;
        for (int i = 0; i < key.length(); i++) {
            char c = key.charAt(i);

            node = node.map.get(c);
            if (node == null) {
                return null;
            }
        }
        return node.value;
    }

    public Trie<T> nodeFor(String character) {
        return this.map.get(character.charAt(0));
    }

    public void set(String key, T value) {
        Trie<T> node = this;
        for (int i = 0; i < key.length(); i++) {
            char c = key.charAt(i);

            Trie<T> current = node;
            node = node.map.get(c);
            if (node == null) {
                node = new Trie<T>();
                current.map.put(c, node);
            }
        }
        node.value = value;
    }

}
