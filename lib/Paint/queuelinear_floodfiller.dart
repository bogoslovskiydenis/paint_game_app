import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:image/image.dart' as img;

class QueueLinearFloodFiller {
  img.Image? image;
  int _width = 0;
  int _height = 0;
  int _cachedWidth = -1;
  int _cachedHeight = -1;
  int _fillColor = 0;
  int _tolerance = 8;
  final List<int> _startColor = [0, 0, 0, 0];
  List<bool>? _pixelsChecked;
  Queue<_FloodFillRange>? _ranges;

  QueueLinearFloodFiller(img.Image imgVal, int newColor) {
    image = imgVal;
    _width = image!.width;
    _height = image!.height;
    setFillColor(newColor);
  }

  void resize(Size size) {
    if (_cachedWidth != size.width.toInt() ||
        _cachedHeight != size.height.toInt()) {
      image = img.copyResize(image!,
          width: size.width.toInt(), height: size.height.toInt());
      _width = image!.width;
      _height = image!.height;
      _cachedWidth = _width;
      _cachedHeight = _height;
    }
  }

  void setTargetColor(int targetColor) {
    _startColor[0] = img.getRed(targetColor);
    _startColor[1] = img.getGreen(targetColor);
    _startColor[2] = img.getBlue(targetColor);
    _startColor[3] = img.getAlpha(targetColor);
  }

  void setTolerance(int value) {
    _tolerance = value.clamp(0, 100);
  }

  int getFillColor() {
    return _fillColor;
  }

  void setFillColor(int value) {
    _fillColor = value;
  }

  void _prepare() {
    // Called before starting flood-fill
    _pixelsChecked = List<bool>.filled(_width * _height, false);
    _ranges = Queue<_FloodFillRange>();
  }

  // Заполняет указанную точку на растровом изображении текущей выбранной заливкой цвет.
  // int x, int y: начальные координаты заливки
  Future<void> floodFill(int x, int y) async {
    // Setup
    _prepare();

    if (_startColor[0] == 0) {
      // ***Get starting color.
      int startPixel = image!.getPixelSafe(x, y);

      _startColor[0] = img.getRed(startPixel);
      _startColor[1] = img.getGreen(startPixel);
      _startColor[2] = img.getBlue(startPixel);
    }

    // ***Do first call to floodfill.
    _linearFill(x, y);

    // ***Вызовите процедуру заполнения,
    // пока диапазоны заполнения все еще существуют на очередь
    _FloodFillRange range;

    while (_ranges!.isNotEmpty) {
      // **Получить следующий диапазон из очереди
      range = _ranges!.removeFirst();


      // Проверка выше и ниже каждого пикселя в диапазоне заливки
      int downPxIdx = (_width * (range.y + 1)) + range.startX;
      int upPxIdx = (_width * (range.y - 1)) + range.startX;
      int upY = range.y - 1; // so we can pass the y coord by ref
      int downY = range.y + 1;

      for (int i = range.startX; i <= range.endX; i++) {
        // *Начать заливку вверх
        // если мы не выше вершины растрового изображения и пикселя выше
        // этот находится в пределах допустимого отклонения цвета

        if (range.y > 0 && (!_pixelsChecked![upPxIdx]) && _checkPixel(i, upY)) {
          _linearFill(i, upY);
        }

        // *Начать заливку вниз
        // если мы не ниже нижней части растрового изображения и пикселя
        // ниже этого находится в пределах допуска цвета
        if (range.y < (_height - 1) &&
            (!_pixelsChecked![downPxIdx]) &&
            _checkPixel(i, downY)) {
          _linearFill(i, downY);
        }

        downPxIdx++;
        upPxIdx++;
      }
    }
  }

  // Находит крайние левую и правую границы области заливки
  // по заданной координате y, начиная с заданной координаты x, заполняя как идет.
  // Добавляет результирующий горизонтальный диапазон в очередь _ranges заливки,
  // для обработки в основном цикле.
  // int x, int y: Начальные координаты
  void _linearFill(int x, int y) {
    // ***Find Left Edge of Color Area
    int lFillLoc = x; // the location to check/fill on the left
    int pxIdx = (_width * y) + x;
    while (true) {
      // **fill with the color
      //pixels[pxIdx] = _fillColor;
      image?.setPixelSafe(lFillLoc, y, _fillColor);

      // **indicate that this pixel has already been checked and filled
      _pixelsChecked![pxIdx] = true;

      // **de-increment
      lFillLoc--; // de-increment counter
      pxIdx--; // de-increment pixel index

      // **exit loop if we're at edge of bitmap or color area
      if (lFillLoc < 0 ||
          (_pixelsChecked![pxIdx]) ||
          !_checkPixel(lFillLoc, y)) {
        break;
      }
    }

    lFillLoc++;

    // ***Find Right Edge of Color Area
    int rFillLoc = x; // the location to check/fill on the left
    pxIdx = (_width * y) + x;

    while (true) {
      // **fill with the color
      image?.setPixelSafe(rFillLoc, y, _fillColor);

      // **указываем, что этот пиксель уже проверен и заполнен
      _pixelsChecked![pxIdx] = true;

      // **increment
      rFillLoc++; // increment counter
      pxIdx++; // increment pixel index

      // **выйти из цикла, если мы находимся на краю
      // растрового изображения или области цвета
      if (rFillLoc >= _width ||
          _pixelsChecked![pxIdx] ||
          !_checkPixel(rFillLoc, y)) {
        break;
      }
    }

    rFillLoc--;
    // add range to queue
    _FloodFillRange r = _FloodFillRange(lFillLoc, rFillLoc, y);
    _ranges?.add(r);
  }

  // Проверяет, находится ли пиксель в пределах допустимого диапазона цветов.
  bool _checkPixel(int x, int y) {
    int pixelColor = image!.getPixelSafe(x, y);
    int red = img.getRed(pixelColor);
    int green = img.getGreen(pixelColor);
    int blue = img.getBlue(pixelColor);
    int alpha = img.getAlpha(pixelColor);

    return (red >= (_startColor[0] - _tolerance) &&
        red <= (_startColor[0] + _tolerance) &&
        green >= (_startColor[1] - _tolerance) &&
        green <= (_startColor[1] + _tolerance) &&
        blue >= (_startColor[2] - _tolerance) &&
        blue <= (_startColor[2] + _tolerance) &&
        alpha >= (_startColor[3] - _tolerance) &&
        alpha <= (_startColor[3] + _tolerance));
  }
}

// Представляет линейный диапазон для заполнения и ответвления от него.
class _FloodFillRange {
  int startX = -1;
  int endX = -1;
  int y = -1;

  _FloodFillRange(int startX, int endX, int yPos) {
    this.startX = startX;
    this.endX = endX;
    this.y = yPos;
  }
}
