import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The button that allows to switch camera.
class SwitchCameraButton extends StatelessWidget {
  /// The mobile scanner controller instance.
  final MobileScannerController controller;

  /// Creates a new switch camera button instance.
  const SwitchCameraButton({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, state, child) {
      if (!state.isInitialized || !state.isRunning) {
        return const SizedBox.shrink();
      }

      int? availableCameras = state.availableCameras;

      if (availableCameras != null && availableCameras < 2) {
        return const SizedBox.shrink();
      }

      return FButton.icon(
        style: FButtonStyle.secondary(),
        onPress: controller.switchCamera,
        child: const Icon(FIcons.switchCamera),
      );
    },
  );
}

/// The button that allows to toggle the flashlight.
class ToggleFlashlightButton extends StatelessWidget {
  /// The mobile scanner controller instance.
  final MobileScannerController controller;

  /// Creates a new toggle flashlight button instance.
  const ToggleFlashlightButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, state, child) {
      if (!state.isInitialized || !state.isRunning) {
        return const SizedBox.shrink();
      }

      switch (state.torchState) {
        case TorchState.auto:
          return FButton.icon(
            style: FButtonStyle.secondary(),
            onPress: controller.toggleTorch,
            child: const Icon(Icons.flash_auto),
          );
        case TorchState.off:
          return FButton.icon(
            style: FButtonStyle.secondary(),
            onPress: controller.toggleTorch,
            child: const Icon(Icons.flash_off),
          );
        case TorchState.on:
          return FButton.icon(
            style: FButtonStyle.secondary(),
            onPress: controller.toggleTorch,
            child: const Icon(Icons.flash_on),
          );
        case TorchState.unavailable:
          return const SizedBox.square(
            dimension: 48,
            child: Icon(
              Icons.flash_off,
              size: 32,
              color: Colors.grey,
            ),
          );
      }
    },
  );
}
