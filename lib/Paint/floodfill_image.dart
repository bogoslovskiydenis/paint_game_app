import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'floodfill_painter.dart';

class FloodFillImage extends StatefulWidget {
  /// Изображение для отображения через [ImageProvider].
  /// <br>Вы можете использовать [AssetImage] или [NetworkImage].
  final ImageProvider imageProvider;

  /// [Color] use for filling the area.
  final Color fillColor;

  // Установите [false], если хотите отключить функцию заполнения при касании.
  // <br>Значение по умолчанию [true].
  final bool isFillActive;

  /// Список цветов, определяющий, к какому [Color]
  // необходимо избегать при касании.
  // <br>**Примечание.** Применяется ближайший цветовой оттенок.
  final List<Color>? avoidColor;

  // Установите значение заполнения [допуск] в диапазоне от 0 до 100.
  // <br>Значение по умолчанию – 8.
  final int tolerance;

  // Ширина изображения.
  // Ширина родительского виджета будет иметь приоритет,
  // если она предоставлена и меньше ширины изображения.
  final int? width;

  // Высота изображения.
  // Высота родительского виджета будет иметь приоритет,
  // если она указана и меньше высоты изображения.
  final int? height;

  // Alignment of the image.
  final AlignmentGeometry? alignment;

  // [Widget] для отображения во время обработки изображения при инициализации.
  /// <br>По умолчанию используется [CircularProgressIndicator].
  final Widget? loadingWidget;

  /// Функция обратного вызова, которая возвращает позицию касания и [Image] из *dart:ui*, когда начинается заливка.
  // <br>**Примечание.** Координата касания зависит от размера изображения.
  final Function(Offset position,ui.Image image)? onFloodFillStart;

  /// Функция обратного вызова, которая возвращает [Image] из *dart:ui*
  /// , когда заливка закончилась.
  final Function(ui.Image image)? onFloodFillEnd;

  // Виджет Flutter, который может использовать
  // функциональность ведра с краской на предоставленном изображении.
  const FloodFillImage(
      {Key? key,
      required this.imageProvider,
      required this.fillColor,
      this.isFillActive = true,
      this.avoidColor,
      this.tolerance = 8,
      this.width,
      this.height,
      this.alignment,
      this.loadingWidget,
      this.onFloodFillStart,
      this.onFloodFillEnd})
      : super(key: key);

  @override
  _FloodFillImageState createState() => _FloodFillImageState();
}

class _FloodFillImageState extends State<FloodFillImage> {
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  double? _width;
  double? _height;
  FloodFillPainter? _painter;
  ValueNotifier<String>? _repainter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resizeImage();
    _getImage();
  }

  @override
  void didUpdateWidget(FloodFillImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _resizeImage();
      _getImage();
    }
  }

  void _resizeImage() {
    _imageProvider = widget.imageProvider;
    if (widget.width != null) {
      _imageProvider = ResizeImage(widget.imageProvider, width: widget.width);
    }
    if (widget.height != null) {
      _imageProvider = ResizeImage(widget.imageProvider, height: widget.height);
    }
  }

  void _getImage() {
    final ImageStream? oldImageStream = _imageStream;
    _imageStream = _imageProvider?.resolve(createLocalImageConfiguration(context));
    if (_imageStream?.key != oldImageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream?.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    _width = _imageInfo?.image.width.toDouble();
    _height = _imageInfo?.image.height.toDouble();
    _repainter = ValueNotifier("");
    _painter = FloodFillPainter(
        image: _imageInfo!.image,
        fillColor: widget.fillColor,
        notifier: _repainter,
        onFloodFillStart: widget.onFloodFillStart,
        onFloodFillEnd: widget.onFloodFillEnd,
        onInitialize: () {
          setState(() {
            //make sure painter is properly initialize
          });
        });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_painter != null) {
      _painter?.setFillColor(widget.fillColor); //incase we want to update fillColor
      _painter?.setAvoidColor(widget.avoidColor!);
      _painter?.setTolerance(widget.tolerance);
      _painter?.setIsFillActive(widget.isFillActive);
    }
    return (_imageInfo != null)
        ? LayoutBuilder(builder: (context, BoxConstraints constraints) {
            double w = _width!;
            double h = _height!;
            if (!constraints.maxWidth.isInfinite) {
              if (constraints.maxWidth < _width!) {
                w = constraints.maxWidth;
              }
            }

            if (!constraints.maxHeight.isInfinite) {
              if (constraints.maxHeight < _height!) {
                h = constraints.maxHeight;
              }
            }

            // print(" constraint max width " + constraints.maxWidth.toString());
            // print(" constraint max height " + constraints.maxHeight.toString());
            // print(" w " + w.toString());
            // print(" h " + h.toString());

            _painter!.setSize(Size(w, h));
            return (widget.alignment == null)
                ? RepaintBoundary(child: CustomPaint(painter: _painter, size: Size(w, h)))
                : Align(
                    alignment: widget.alignment!,
                    child: CustomPaint(painter: _painter, size: Size(w, h)));
          })
        : (widget.loadingWidget == null)
            ? const CircularProgressIndicator()
            : widget.loadingWidget!;
  }
}
