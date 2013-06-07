part of tilebasedwordsearch;

class TileSet {
  static const Map<String, num> LETTER_SCORES =  const {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
    'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1,
    'P': 3, 'QU': 10, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4,'W': 4, 'X': 8, 'Y': 4, 'Z': 10};
    
  static const List<String> tiles = const <String>[
    'K',
    'J',
    'X',
    'QU',
    'QU',
    'Z',
    'B',
    'B',
    'C',
    'C',
    'M',
    'M',
    'P',
    'P',
    'F',
    'F',
    'H',
    'H',
    'V',
    'V',
    'W',
    'W',
    'Y',
    'Y',
    'G',
    'G',
    'G',
    'L',
    'L',
    'L',
    'L',
    'S',
    'S',
    'S',
    'S',
    'U',
    'U',
    'U',
    'U',
    'D',
    'D',
    'D',
    'D',
    'N',
    'N',
    'N',
    'N',
    'N',
    'N',
    'R',
    'R',
    'R',
    'R',
    'R',
    'R',
    'T',
    'T',
    'T',
    'T',
    'T',
    'T',
    'O',
    'O',
    'O',
    'O',
    'O',
    'O',
    'O',
    'O',
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
    'I',
    'I',
    'I',
    'I',
    'I',
    'I',
    'I',
    'I',
    'I',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E',
    'E'];

  static List<String> getTilesForGame(int gameId) {
    Random random = new Random(gameId);
    List<bool> usedTiles = new List<bool>.filled(tiles.length, false);
    List<String> selectedTiles = new List<String>();
    while (selectedTiles.length < 16) {
      do {
        int index = random.nextInt(tiles.length);
        if (usedTiles[index] == false) {
          usedTiles[index] = true;
          selectedTiles.add(tiles[index]);
          break;
        }
      } while(true);
    }
    return selectedTiles;
  }
}