part of tilebasedwordsearch;

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  final int WIDTH = 320;
  final int HEIGHT = 320;
  final int NUM_TILES = 4;

  num tileSize;
  num gapSize;

  RectangleTransform canvasTransform;
  CanvasElement canvas;
  final List<RectangleTransform> letterTiles = new List<RectangleTransform>();
  final Set<int> selectedTiles = new Set<int>();
  String selectedLetters = '';

  // Reference to the main game object.
  final Board game;

  // TODO: Set these.
  String defaultColor;
  String selectedColor;

  BoardView(this.game, this.canvas) {
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
    for (int i = 0; i < NUM_TILES; i++) {
      for (int j = 0; j < NUM_TILES; j++) {
        num x = (i * (tileSize + gapSize)).toInt();
        num y = (j * (tileSize + gapSize)).toInt();
        num width = tileSize.toInt();
        num height = tileSize.toInt();
        letterTiles[tileIndex(i, j)] =
            new RectangleTransform.raw(x, y, width, height);
      }
    }
  }

  void selectSearchString(String searchString) {
    Set<List<int>> paths = new Set<List<int>>();
    selectedTiles.clear();
    if (game.stringInGrid(searchString, paths)) {
      paths.forEach((path) {
        for (int i = 0; i < path.length; i++) {
          selectedTiles.add(path[i]);
        }
      });
    }
  }
  
  int tileIndex(int row, int column) {
    return row*4+column;
  }

  RectangleTransform getTileRectangle(int row, int column) {
    return letterTiles[tileIndex(row, column)];
  }

  TileCoord getTileCoord(int row, int column) {
    num x = column * (tileSize + gapSize);
    num y = row * (tileSize + gapSize);
    return new TileCoord(x, y);
  }

  void drawTile(String letter, int score) {
    // TODO.
  }


  void update(GameLoopTouch touch) {
    if (touch != null) {
      int selectedIndex = 0;
      for (int i = 0; i < NUM_TILES; i++) {
        for (int j = 0; j < NUM_TILES; j++) {
          var transform = getTileRectangle(i, j);
          for (var position in touch.positions) {
            if (transform.contains(position.x, position.y)) {
              int index = tileIndex(i,j);
              if (selectedTiles.contains(index) == false) {
                selectedTiles.add(tileIndex(i, j));
                selectedLetters = '$selectedLetters${game.grid[i][j]}';
              }
            }
          }
        }
      }
    } else {
      selectedTiles.clear();
      selectedLetters = '';
    }
    if (selectedTiles.length > 0) {
      print(selectedTiles);
      print(selectedLetters);
    }
  }

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
      var elementName = game.grid[i ~/ NUM_TILES][i % NUM_TILES];
      letterAtlas.draw(elementName, c, x, y);
      c.fillText(TileSet.LETTER_SCORES[elementName].toString(), x + X_OFFSET, y + Y_OFFSET);
    }

    return;

    // Loop through the tiles and draw each one.
    for (int i = 0; i < NUM_TILES; i++) { // each row
      for (int j = 0; j < NUM_TILES; j++) { // each column

        var coord = getTileCoord(i, j);

        // Draw tile background.
        c.fillStyle = '#f00';
        c.fillRect(coord.x, coord.y, tileSize, tileSize);

        // Draw large letter.
        c.fillStyle = '#000';
        c.font = '${(tileSize).floor() / 3 * 2}px sans-serif';
        c.textBaseline = 'middle';

        var text = game.grid[i][j];
        var width = c.measureText(text).width.clamp(0, tileSize);

        var textOffset = (tileSize - width) / 2;

        c.fillText(text, coord.x + textOffset, coord.y + tileSize * 0.5);

        // Draw points.
        c.fillStyle = '#000';
        c.font = '10px sans-serif';
        c.textBaseline = 'middle';
        text = TileSet.LETTER_SCORES[game.grid[i][j]].toString();
        width = c.measureText(text).width;

        c.fillText(text, coord.x + tileSize - width - /* padding */ 3, coord.y + /* half font size */ 5 + /* padding */ 3);
      }
    }
  }
}
