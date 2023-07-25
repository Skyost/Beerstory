import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Displays a beer animation.
class BeerAnimationDialog extends StatefulWidget {
  /// Triggered when finished.
  final VoidCallback onFinished;

  /// Creates a new beer animation dialog instance.
  const BeerAnimationDialog({super.key, required this.onFinished,});

  @override
  State<StatefulWidget> createState() => _BeerAnimationDialogState();

  /// Shows the dialog only for the duration of the animation.
  static Future<void> show({
    required BuildContext context,
  }) => showDialog(
      context: context,
      builder: (context) => BeerAnimationDialog(
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
  Widget build(BuildContext context) => AlertDialog(
        content: Lottie.asset(
          'assets/animations/beer.json',
          controller: controller,
          onLoaded: (composition) {
            controller.duration = composition.duration;
            TickerFuture tickerFuture = controller.forward();
            tickerFuture.whenCompleteOrCancel(widget.onFinished);
          }
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
