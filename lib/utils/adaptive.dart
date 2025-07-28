import 'package:beerstory/spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Allows to adapt the widget list to the platform.
extension Adaptive on List<FButton> {
  /// Returns the wrapper according to the platform.
  Widget get adaptiveWrapper => defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android
      ? Column(
          spacing: kSpace,
          children: this,
        )
      : Wrap(
          spacing: kSpace / 2,
          runSpacing: kSpace,
          alignment: WrapAlignment.end,
          children: [
            for (Widget button in this)
              IntrinsicWidth(
                child: button,
              ),
          ],
        );
}
