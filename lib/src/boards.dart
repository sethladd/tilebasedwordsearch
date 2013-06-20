part of shared;

class Boards {
  
  List<BoardAndWords> boards = new List<BoardAndWords>();
  Random _rand = new Random();

  Boards(String data) {
    final StringBuffer tiles = new StringBuffer();
    
    final RegExp boardRow = new RegExp(r'^[A-Z] [A-Z] [A-Z] [A-Z]$');
    final RegExp scoreRow = new RegExp(r'^[0-9]+ [0-9]+');
    bool nextLineIsWords = false;
    
    data.split('\n').forEach((String line) {
      if (boardRow.hasMatch(line.trim())) {
        var chars = line.split(' ').join('');
        tiles.write(chars);
      } else if (nextLineIsWords) {
        String board = tiles.toString();
        final List<String> words = line.split(' ');
        
        boards.add(new BoardAndWords(board, words));
        
        tiles.clear();
        words.clear();
        nextLineIsWords = false;
      } else {
        nextLineIsWords = true;
      }
    });
  }
  
  BoardAndWords getRandomBoard() {
    var index = _rand.nextInt(boards.length);
    return boards[index];
  }

}

class BoardAndWords {
  final String board;
  final List<String> words;
  
  BoardAndWords(this.board, this.words);
  
  bool hasWord(String word) => words.contains(word);
}