// ignore_for_file: prefer_const_constructors

import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget displaying an error.
class ErrorWidget extends StatefulWidget {
  /// The error.
  final Object error;

  /// The stacktrace.
  final StackTrace? stackTrace;

  /// The callback to call when the user wants to retry.
  final VoidCallback? onRetryPressed;

  /// Creates an error widget.
  const ErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetryPressed,
  });

  @override
  State<StatefulWidget> createState() => _ErrorWidgetState();
}

/// The error widget state.
class _ErrorWidgetState extends State<ErrorWidget> with SingleTickerProviderStateMixin<ErrorWidget> {
  /// The animation controller.
  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  /// The reveal stacktrace animation.
  late final Animation<double> animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeInOut,
  );

  /// Whether the stacktrace is expanded.
  bool expanded = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace),
            child: FAlert(
              title: Text(translations.error.widget.title),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: kSpace),
                    child: Text(translations.error.widget.subtitle(error: widget.error)),
                  ),
                  if (widget.stackTrace != null)
                   ...[
                     FSwitch(
                       label: Text(expanded ? translations.error.widget.button.hideTrace : translations.error.widget.button.showTrace),
                       value: expanded,
                       onChange: toggleStackTrace,
                       style: (style) => style.copyWith(
                         childPadding: EdgeInsets.only(right: style.childPadding.horizontal / 2),
                         trackColor: FWidgetStateMap<Color>({
                           WidgetState.selected: context.theme.colors.error,
                           WidgetState.any: context.theme.colors.error.withValues(alpha: 0.25),
                         }),
                         labelTextStyle: FWidgetStateMap<TextStyle>.all(style.errorTextStyle),
                       ),
                     ),
                     AnimatedBuilder(
                       animation: animation,
                       builder: (context, child) => FCollapsible(
                         value: animation.value,
                         child: child!,
                       ),
                       child: Text(
                         widget.stackTrace.toString(),
                         style: TextStyle(fontSize: context.theme.typography.xs.fontSize),
                       ),
                     ),
                   ]
                ],
              ),
              style: FAlertStyle.destructive(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace),
            child: FutureBuilder(
              future: canLaunchUrl(reportIssueUrl),
              builder: (context, asyncSnapshot) => FButton(
                onPress: asyncSnapshot.data == true ? () => launchUrl(reportIssueUrl) : null,
                style: FButtonStyle.outline(),
                prefix: Icon(FIcons.bug),
                child: Text(translations.error.widget.button.report),
              ),
            ),
          ),
          if (widget.onRetryPressed != null)
            FButton(
              onPress: widget.onRetryPressed,
              prefix: Icon(FIcons.refreshCcw),
              child: Text(translations.error.widget.button.retry),
            ),
        ],
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// The issues URL.
  Uri get reportIssueUrl =>
      Uri.parse('https://github.com/Skyost/Beerstory/issues?labels=bug&title=${Uri.encodeComponent('`${widget.error}`')}&body=${Uri.encodeComponent((widget.stackTrace ?? 'No stacktrace').toString())}');

  /// Toggles the stacktrace.
  void toggleStackTrace([bool? value]) {
    setState(() => expanded = value ?? !expanded);
    controller.toggle();
  }
}
