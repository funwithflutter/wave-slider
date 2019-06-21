import 'package:flutter/material.dart';
import 'package:wave_slider/src/wave_painter.dart';

class WaveSlider extends StatefulWidget {
  WaveSlider({
    this.sliderWidth = 350.0,
    this.sliderHeight = 50.0,
    this.color = Colors.black,
    this.onChangeEnd,
    this.onChangeStart,
    @required this.onChanged,
  })  : assert(sliderHeight >= 50 && sliderHeight <= 600),
        assert(sliderWidth > 0),
        assert(onChanged != null &&
            color != null &&
            sliderWidth != null &&
            sliderHeight != null);

  final double sliderWidth;
  final double sliderHeight;
  final Color color;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  @override
  _WaveSliderState createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  double _dragPercentage = 0.0;

  WaveSliderController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = WaveSliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleChanged(double val) {
    if (widget.onChanged != null) {
      widget.onChanged(val);
    }
  }

  void _handleChangeStart(double val) {
    if (widget.onChangeStart != null) {
      widget.onChangeStart(val);
    }
  }

  void _handleChangeEnd(double val) {
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd(val);
    }
  }

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0.0;
    if (val.dx <= 0.0) {
      newDragPosition = 0.0;
    } else if (val.dx >= widget.sliderWidth) {
      newDragPosition = widget.sliderWidth;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.sliderWidth;
    });
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(start.globalPosition);
    _slideController.setStateToStart();
    _updateDragPosition(localOffset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(update.globalPosition);
    _slideController.setStateToSliding();
    _updateDragPosition(localOffset);
    _handleChanged(_dragPercentage);
    print(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _slideController.setStateToStopping();
    setState(() {});
    _handleChangeEnd(_dragPercentage);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.sliderWidth,
        height: widget.sliderHeight,
        child: CustomPaint(
          painter: WavePainter(
            color: widget.color,
            sliderPosition: _dragPosition,
            dragPercentage: _dragPercentage,
            sliderState: _slideController.state,
            animationProgress: _slideController.progress,
          ),
        ),
      ),
      onHorizontalDragStart: (DragStartDetails start) =>
          _onDragStart(context, start),
      onHorizontalDragUpdate: (DragUpdateDetails update) =>
          _onDragUpdate(context, update),
      onHorizontalDragEnd: (DragEndDetails end) => _onDragEnd(context, end),
    );
  }
}

class WaveSliderController extends ChangeNotifier {
  WaveSliderController({@required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final AnimationController controller;
  SliderState _state = SliderState.resting;

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionCompleted();
    }
  }

  void _onTransitionCompleted() {
    if (_state == SliderState.stopping) {
      setStateToResting();
    }
  }

  double get progress => controller.value;

  SliderState get state => _state;

  void _startAnimation() {
    controller.duration = Duration(milliseconds: 500);
    controller.forward(from: 0.0);
    notifyListeners();
  }

  void setStateToStart() {
    _startAnimation();
    _state = SliderState.starting;
  }

  void setStateToStopping() {
    _startAnimation();
    _state = SliderState.stopping;
  }

  void setStateToSliding() {
    _state = SliderState.sliding;
  }

  void setStateToResting() {
    _state = SliderState.resting;
  }
}

enum SliderState {
  starting,
  resting,
  sliding,
  stopping,
}
