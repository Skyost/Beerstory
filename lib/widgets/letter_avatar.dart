import 'package:flutter/material.dart';

/// A simple image that displays a letter.
class LetterAvatar extends StatelessWidget {
  /// The radius.
  final double radius;

  /// The text.
  final String? text;

  /// Creates a new letter avatar instance.
  const LetterAvatar({
    super.key,
    this.radius = 100,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        radius: radius,
        child: Text(
          _textToWrite,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: radius,
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      );

  /// Returns the text to write.
  String get _textToWrite {
    if (this.text == null) {
      return '?';
    }

    String text = this.text!.replaceAll(RegExp(r'[^\s\w]'), '').trim().toUpperCase();
    if (text.isEmpty) {
      return '?';
    }

    List<String> parts = text.split(' ');
    if (parts.length == 1) {
      List<String> otherSplit = text.split('-');
      if (otherSplit.length > 1 && otherSplit[1].isNotEmpty) {
        return otherSplit[0][0] + otherSplit[1][0];
      }

      if (text.length == 2) {
        return text;
      }

      return parts[0][0];
    }

    return parts[0][0] + parts[1][0];
  }
}
