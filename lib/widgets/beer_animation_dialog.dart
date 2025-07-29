import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lottie/lottie.dart';

/// Displays a beer animation.
class BeerAnimationDialog extends StatefulWidget {
  /// Triggered when finished.
  final VoidCallback onFinished;

  /// The dialog style.
  final FDialogStyle Function(FDialogStyle)? _style;

  /// The animation.
  final Animation<double>? _animation;

  /// Creates a new beer animation dialog instance.
  const BeerAnimationDialog({
    super.key,
    required this.onFinished,
    FDialogStyle Function(FDialogStyle)? style,
    Animation<double>? animation,
  })  : _style = style,
        _animation = animation;

  @override
  State<StatefulWidget> createState() => _BeerAnimationDialogState();

  /// Shows the dialog only for the duration of the animation.
  static Future<void> show({
    required BuildContext context,
  }) =>
      showFDialog(
        context: context,
        builder: (context, style, animation) => BeerAnimationDialog(
          style: style.call,
          animation: animation,
          onFinished: () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        barrierDismissible: false,
      );
}

/// The beer animation dialog state.
class _BeerAnimationDialogState extends State<BeerAnimationDialog> with TickerProviderStateMixin {
  /// The animation controller.
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) => FDialog(
        style: widget._style,
        animation: widget._animation,
        body: Lottie.asset(
          'assets/animations/beer.json',
          controller: controller,
          onLoaded: (composition) {
            controller.duration = composition.duration;
            TickerFuture tickerFuture = controller.forward();
            tickerFuture.whenCompleteOrCancel(widget.onFinished);
          },
        ),
        actions: [],
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
