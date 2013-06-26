part of tilebasedwordsearch;

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
  }

  bool containsLine(int x0, int y0, int x1, int y1) {
    return _containsLine(x0.toDouble(), y0.toDouble(), x1.toDouble(),
                         y1.toDouble(), left.toDouble(), right.toDouble(),
                         top.toDouble(), bottom.toDouble());
  }

  /// Transform [x] into the [this] coordinate system.
  int transformX(int x) => x - left;
  /// Transform [y] into the [this] coordinate system.
  int transformY(int y) => y - top;

  String toString() => '[$left,$top], [$right, $bottom]';
}
