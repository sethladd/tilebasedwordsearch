part of tilebasedwordsearch;

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

  BoardView(this.board, this.canvas) {
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

  double get scaleX => canvas.clientWidth/canvas.width;
  double get scaleY => canvas.clientHeight/canvas.height;

  void render() {
    var c = canvas.context2D;
    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    for (int i = 0; i < letterTiles.length; i++) {
      int x = letterTiles[i].left;
      int y = letterTiles[i].top;
      if (selectedTiles.contains(i)) {
        c.strokeStyle = '#ff0000';
      } else {
        c.strokeStyle = '#000000';
      }
      letterTiles[i].drawOutline(canvas);

      var elementName = board.config.getChar(
          GameConstants.rowFromIndex(i),
          GameConstants.columnFromIndex(i));
      letterAtlas.draw(elementName, c, x, y);
    }
  }
}
