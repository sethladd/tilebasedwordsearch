part of tilebasedwordsearch;

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  int WIDTH = 320;
  int HEIGHT = 320;

  num tileSize;
  num gapSize;

  CanvasElement canvas;

  // TODO: Set these.
  String defaultColor;
  String selectedColor;

  BoardView(CanvasElement this.canvas) {
    init();
  }

  void init() {
    canvas.width = WIDTH;
    canvas.height = HEIGHT;

    var constraint = min(WIDTH, HEIGHT);
    tileSize = constraint / 4.75;
    gapSize = tileSize * 0.25;

  }

  TileCoord getTileCoord(int row, int column) {
    num x = column * (tileSize + gapSize);
    num y = row * (tileSize + gapSize);
    return new TileCoord(x, y);
  }

  void drawTile(String letter, int score) {
    // TODO.
  }

  void render() {
    var c = canvas.context2d;

    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    // Loop through the tiles and draw each one.
    for (int i = 0; i < 4; i++) { // each row
      for (int j = 0; j < 4; j++) { // each column

        var coord = getTileCoord(i, j);

        // Draw tile background.
        c.fillStyle = '#f00';
        c.fillRect(coord.x, coord.y, tileSize, tileSize);

        // Draw large letter.
        c.fillStyle = '#000';
        c.font = '${(tileSize).floor() / 3 * 2}px sans-serif';
        c.textBaseline = 'middle';

        var text = '$i';
        var width = c.measureText(text).width.clamp(0, tileSize);

        var textOffset = (tileSize - width) / 2;

        c.fillText(text, coord.x + textOffset, coord.y + tileSize * 0.5);

        // Draw points.
        c.fillStyle = '#000';
        c.font = '10px sans-serif';
        c.textBaseline = 'middle';
        text = '1';
        width = c.measureText(text).width;

        c.fillText(text, coord.x + tileSize - width - /* padding */ 3, coord.y + /* half font size */ 5 + /* padding */ 3);
      }
    }


  }
}
