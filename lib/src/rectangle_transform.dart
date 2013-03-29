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

  /// Bottom.
  int get bottom => top + height;
  /// Right.
  int get right => left + width;

  /// Is [x] and [y] contained by this rectangle?
  bool contains(int x, int y) {
    return left <= x && x <= right && top <= y && y <= bottom;
  }

  /// Transform [x] into the [this] coordinate system.
  int transformX(int x) => x - left;
  /// Transform [y] into the [this] coordinate system.
  int transformY(int y) => y - top;

  String toString() => '[$left,$top], [$right, $bottom]';
}