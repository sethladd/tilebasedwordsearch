library image_atlas;

import 'dart:html';

class ImageAtlasElement {
  final String name;
  final Rectangle rect;
  ImageAtlasElement(this.name, x, y, width, height) :
    this.rect = new Rectangle(x, y, width, height);
}

class ImageAtlas {
  final ImageElement image;
  final Map<String, ImageAtlasElement> elements =
      new Map<String, ImageAtlasElement>();

  ImageAtlas(this.image);

  void addElement(String name, int x, int y, int width, int height) {
    elements[name] = new ImageAtlasElement(name, x, y, width, height);
  }

  void draw(String atlasElementName, CanvasRenderingContext2D context, int x,
            int y) {
    var atlasElement = elements[atlasElementName];
    if (atlasElement == null) {
      print('no atlas for $atlasElementName');
      return;
    }
    Rectangle destRect = new Rectangle(x, y, atlasElement.rect.width,
                             atlasElement.rect.height);
    context.drawImageToRect(image, destRect, sourceRect:atlasElement.rect);
  }
}
