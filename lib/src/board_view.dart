part of tilebasedwordsearch;

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  final int WIDTH = 800;
  final int HEIGHT = 600;
  CanvasElement canvas;
  final Set<int> selectedTiles = new Set<int>();

  num tileSize;
  num gapSize;

  RectangleTransform canvasTransform;
  final List<RectangleTransform> letterTiles = new List<RectangleTransform>();

  final Board board;

  BoardView(this.board, this.canvas) {
    letterTiles.length = 16;
    init();
  }


  void init() {
    canvas.width = WIDTH;
    canvas.height = HEIGHT;

    var constraint = min(WIDTH, HEIGHT);

    tileSize = constraint / 4.75;
    gapSize = tileSize * 0.25;

    // Loop through the tiles and draw each one.
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        num x = (i * (tileSize + gapSize)).toInt();
        num y = (j * (tileSize + gapSize)).toInt();
        num width = tileSize.toInt();
        num height = tileSize.toInt();
        letterTiles[GameConstants.rowColumnToIndex(i, j)] =
            new RectangleTransform.raw(x, y, width, height);
      }
    }
  }

  RectangleTransform getTileRectangle(int row, int column) {
    return letterTiles[GameConstants.rowColumnToIndex(row, column)];
  }

  TileCoord getTileCoord(int row, int column) {
    num x = column * (tileSize + gapSize);
    num y = row * (tileSize + gapSize);
    return new TileCoord(x, y);
  }

  double get scaleX => canvas.clientWidth/canvas.width;
  double get scaleY => canvas.clientHeight/canvas.height;

  void render() {
    var c = canvas.context2D;
    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    const int X_OFFSET = 5;
    const int Y_OFFSET = 60;

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
      c.fillText(GameConstants.letterScores[elementName].toString(),
                 x + X_OFFSET, y + Y_OFFSET);
    }
  }
}
