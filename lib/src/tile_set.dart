part of tilebasedwordsearch;

class TileSet {
  final List<String> tiles = new List<String>();

  TileSet() {
    tiles.add('K');
    tiles.add('J');
    tiles.add('X');
    tiles.add('QU');
    tiles.add('QU');
    tiles.add('Z');
    tiles.add('B');
    tiles.add('B');
    tiles.add('C');
    tiles.add('C');
    tiles.add('M');
    tiles.add('M');
    tiles.add('P');
    tiles.add('P');
    tiles.add('F');
    tiles.add('F');
    tiles.add('H');
    tiles.add('H');
    tiles.add('V');
    tiles.add('V');
    tiles.add('W');
    tiles.add('W');
    tiles.add('Y');
    tiles.add('Y');
    tiles.add('G');
    tiles.add('G');
    tiles.add('G');
    tiles.add('L');
    tiles.add('L');
    tiles.add('L');
    tiles.add('L');
    tiles.add('S');
    tiles.add('S');
    tiles.add('S');
    tiles.add('S');
    tiles.add('U');
    tiles.add('U');
    tiles.add('U');
    tiles.add('U');
    tiles.add('D');
    tiles.add('D');
    tiles.add('D');
    tiles.add('D');
    tiles.add('N');
    tiles.add('N');
    tiles.add('N');
    tiles.add('N');
    tiles.add('N');
    tiles.add('N');
    tiles.add('R');
    tiles.add('R');
    tiles.add('R');
    tiles.add('R');
    tiles.add('R');
    tiles.add('R');
    tiles.add('T');
    tiles.add('T');
    tiles.add('T');
    tiles.add('T');
    tiles.add('T');
    tiles.add('T');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('O');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('A');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('I');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
    tiles.add('E');
  }

  List<String> getTilesForGame(int gameId) {
    Random random = new Random(gameId);
    List<bool> usedTiles = new List<bool>(tiles.length);
    for (int i = 0; i < usedTiles.length; i++) {
      usedTiles[i] = false;
    }
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