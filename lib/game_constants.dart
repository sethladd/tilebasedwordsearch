library game_constants;

class GameConstants {
  static const int TilePixels = 94;
  static const int TileGap = 6;
  static const int BoardDimension = 4;
  static const Map letterScores = const {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
    'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1,
    'P': 3, 'QU': 10, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4,'W': 4, 'X': 8, 'Y': 4, 'Z': 10
  };

  static int rowColumnToIndex(int row, int col) {
    return row * GameConstants.BoardDimension + col;
  }

  static int rowFromIndex(int row) {
    return row ~/ GameConstants.BoardDimension;
  }

  static int columnFromIndex(int column) {
    return column % GameConstants.BoardDimension;
  }

  static List<String> convertStringToTileList(String str) {
    List<String> tileString = [];
    for (int i = 0; i < str.length; i++) {
      if ((str[i] == 'Q' && i+1 >= str.length) ||
          (str[i] == 'Q' && str[i+1] != 'U')) {
        // Q must always be followed by a U.
        return [];
      }
      if (str[i] == 'Q') {
        tileString.add('QU');
        i++;
      } else {
        tileString.add(str[i]);
      }
    }
    return tileString;
  }
}
