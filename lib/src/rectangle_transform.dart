part of wordherd;

class RectangleTransform {
  /// Left.
  final int left;
  /// Top.
  final int top;
  /// Width.
  final int width;
  /// Height.
  final int height;
  /// Construct a [RectangleTransform] from an element.
  RectangleTransform(Element element) : this.left = element.offsetLeft,
                                        this.top = element.offsetTop,
                                        this.width = element.clientWidth,
                                        this.height = element.clientHeight;
  /// Construct a [RectangleTransform] from raw coordinates.
  RectangleTransform.raw(this.left, this.top, this.width, this.height);

  /// Draw the rectangle outline in element.
  void drawOutline(CanvasElement element) {
    var context = element.getContext('2d');
    context.strokeRect(left, top, width, height);
  }

  /// Bottom.
  int get bottom => top + height;
  /// Right.
  int get right => left + width;

  /// Is [x] and [y] contained by this rectangle?
  bool contains(int x, int y) {
    return left <= x && x <= right && top <= y && y <= bottom;
  }

  bool containsTouch(int x, int y) {
    int xChop = (width * 0.10).toInt();
    int yChop = (height * 0.10).toInt();

    return left+xChop <= x && x <= right-xChop &&
           top+yChop <= y && y <= bottom-yChop;
  }

  // Return < 0
  double lineSide(double x0, double y0, double x1, double y1,
                  double x, double y) {
    return (y1-y0)*x + (x0-x1)*y + (x1*y0-x0*y1);
  }

  bool _containsLine(double x0, double y0, double x1, double y1,
                     double l, double r, double t, double b) {
    double _a = lineSide(x0, y0, x1, y1, l, t);
    double _b = lineSide(x0, y0, x1, y1, l, b);
    double _c = lineSide(x0, y0, x1, y1, r, t);
    double _d = lineSide(x0, y0, x1, y1, r, b);
    // All four corners on negative side.
    if (_a < 0.0 && _b < 0.0 && _c < 0.0 && _d < 0.0) {
      return false;
    }
    // All four corners on positive side.
    if (_a > 0.0 && _b > 0.0 && _c > 0.0 && _d > 0.0) {
      return false;
    }
    // Line is to the right.
    if (x0 > r && x1 > r) {
      return false;
    }
    // Line is to the left.
    if (x0 < l && x1 < l) {
      return false;
    }
    // Line is above.
    if (y0 > t && y1 > t) {
      return false;
    }
    // Line is below.
    if (y0 < b && y0 < b) {
      return false;
    }
    return true;
  }

  bool containsLine(int x0, int y0, int x1, int y1) {
    int xChop = (width * 0.10).toInt();
    int yChop = (height * 0.10).toInt();
    return _containsLine(x0.toDouble(), y0.toDouble(), x1.toDouble(),
                         y1.toDouble(), (left+xChop).toDouble(),
                         (right-xChop).toDouble(),
                         (top+yChop).toDouble(), (bottom-yChop).toDouble());
  }

  /// Transform [x] into the [this] coordinate system.
  int transformX(int x) => x - left;
  /// Transform [y] into the [this] coordinate system.
  int transformY(int y) => y - top;

  String toString() => '[$left,$top], [$right, $bottom]';
}
