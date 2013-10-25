part of client_game;

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  final int WIDTH = GameConstants.BoardDimension *
                    (GameConstants.TileGap + GameConstants.TilePixels);
  final int HEIGHT = GameConstants.BoardDimension *
                    (GameConstants.TileGap + GameConstants.TilePixels);

  final List<RectangleTransform> letterTiles = new List<RectangleTransform>();
  final Board board;
  final CanvasElement canvas;
  final Set<int> selectedTiles = new Set<int>();
  
  // XXX fixme
  ImageAtlas tripleWordAtlas, letterAtlas, selectedLetterAtlas, tripleLetterAtlas;

  BoardView(this.board, this.canvas, this.tripleWordAtlas, this.letterAtlas,
      this.selectedLetterAtlas, this.tripleLetterAtlas) {
    letterTiles.length = 16;
    init();
  }

  void init() {
    canvas.width = WIDTH;
    canvas.height = HEIGHT;
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        num x = i * (GameConstants.TileGap + GameConstants.TilePixels);
        num y = j * (GameConstants.TileGap + GameConstants.TilePixels);
        num width = GameConstants.TilePixels;
        num height = GameConstants.TilePixels;
        letterTiles[GameConstants.rowColumnToIndex(i, j)] =
            new RectangleTransform.raw(x, y, width, height);
      }
    }
  }

  RectangleTransform getTileRectangle(int row, int column) {
    return letterTiles[GameConstants.rowColumnToIndex(row, column)];
  }

  TileCoord getTileCoord(int row, int column) {
    num x = row * (GameConstants.TileGap + GameConstants.TilePixels);
    num y = column * (GameConstants.TileGap + GameConstants.TilePixels);
    return new TileCoord(x, y);
  }

  double get scaleX => canvas.width/canvas.clientWidth;
  double get scaleY => canvas.height/canvas.clientHeight;

  int transformTouchToCanvasX(num v) {
    // WTF if I make that var a Rectangle, then it explodes the whole library import
    var canvasRectangle = canvas.getBoundingClientRect();
    int offsetX = (canvasRectangle.left + document.body.scrollLeft).toInt();
    int x = ((v - offsetX) * scaleX).toInt();
    return x;
  }

  int transformTouchToCanvasY(num v) {
    var canvasRectangle = canvas.getBoundingClientRect();
    int offsetY = (canvasRectangle.top + document.body.scrollTop).toInt();
    int y = ((v - offsetY) * scaleY).toInt();
    return y;
  }

  void render() {
    var c = canvas.context2D;
    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    for (int i = 0; i < letterTiles.length; i++) {
      int x = letterTiles[i].left;
      int y = letterTiles[i].top;
      var atlas = letterAtlas;
      if (selectedTiles.contains(i)) {
        atlas = selectedLetterAtlas;
      }
      var elementName = board.getChar(
          GameConstants.rowFromIndex(i),
          GameConstants.columnFromIndex(i));
      atlas.draw(elementName, c, x, y);
      if (board.letterBonusTileIndexes.contains(i)) {
        tripleLetterAtlas.draw(elementName, c, x, y);
      } else if (board.wordBonusTileIndex == i) {
        tripleWordAtlas.draw(elementName, c, x, y);
      }
    }
  }

  void renderPauseScreen() {
    var c = canvas.context2D;
    c.clearRect(0, 0, WIDTH, HEIGHT);
    c.createLinearGradient(0, 0, WIDTH, HEIGHT);
    c.fillStyle="#000";
    c.fillRect(0,0,WIDTH,HEIGHT);
  }
}
