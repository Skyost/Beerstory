import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A simple centered text.
class CenteredMessage extends StatelessWidget {
  /// The text key.
  final String textKey;

  /// Creates a new centered message instance.
  const CenteredMessage({
    super.key,
    required this.textKey,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.getString(textKey),
    ),
  );
}
