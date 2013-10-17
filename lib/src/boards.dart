part of wordherd;

class BoardData {
  String tiles;
  List<String> words;
  
  BoardData(this.tiles, this.words);
}

class Boards {

  static Random _random = new Random();
  final List<BoardData> boardDatas = [];

  Boards(String data) {
    final StringBuffer tiles = new StringBuffer();

    data.split('\n').forEach((String line) {
      if (line.trim().length < 32) return;
      String tiles = line.substring(0, 32).split(' ').join('');
      List<String> words = line.substring(33).split(' ');
      boardDatas.add(new BoardData(tiles, words));
    });
  }
  
  Board generateBoard(Game game, {int numBonusLetters: 3}) {
    if (numBonusLetters == null) numBonusLetters = 3;
    int index = _random.nextInt(boardDatas.length);
    BoardData boardData = boardDatas[index];
    List<int> letterBonusTileIndexes = [];
    int wordBonusTileIndex;
    
    while (letterBonusTileIndexes.length < numBonusLetters) {
      int r = _random.nextInt(16);
      if (!letterBonusTileIndexes.contains(r)) {
        letterBonusTileIndexes.add(r);
      }
    }
    
    while (wordBonusTileIndex == null) {
      int r = _random.nextInt(16);
      if (letterBonusTileIndexes.contains(r) == false) {
        wordBonusTileIndex = r;
      }
    }
    
    return new Board(game, boardData.tiles, boardData.words, letterBonusTileIndexes, wordBonusTileIndex);
  }

}
