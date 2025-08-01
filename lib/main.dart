import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/migration/migrator.dart';
import 'package:beerstory/pages/routes.dart';
import 'package:beerstory/pages/scaffold.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Hello world !
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'Beerstory',
    url: 'https://github.com/Skyost/Beerstory',
  );
  OpenFoodAPIConfiguration.globalLanguages = [
    OpenFoodFactsLanguage.ENGLISH,
    OpenFoodFactsLanguage.FRENCH,
  ];
  await LocaleSettings.useDeviceLocale();
  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: _BeerstoryApp(),
      ),
    ),
  );
}

/// The beerstory app class.
class _BeerstoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FThemeData themeData = MediaQuery.of(context).platformBrightness == Brightness.dark ? _tealTheme.dark : _tealTheme.light;
    return MaterialApp(
      title: 'Beerstory',
      builder: (context, child) => FTheme(
        data: themeData.copyWith(
          headerStyles: themeData.headerStyles.copyWith(
            rootStyle: (style) => style.copyWith(
              titleTextStyle: style.titleTextStyle.copyWith(
                fontFamily: 'BirdsOfParadise',
                height: 1.15,
              ),
            ),
            nestedStyle: (style) => style.copyWith(
              titleTextStyle: style.titleTextStyle.copyWith(
                fontFamily: 'BirdsOfParadise',
                fontSize: 24,
                height: 1.15,
              ),
            ),
          ),
          textFieldStyle: themeData.textFieldStyle.copyWith(
            contentTextStyle: themeData.textFieldStyle.contentTextStyle.map(
              (style) => style.copyWith(
                color: themeData.colors.foreground,
              ),
            ),
          ),
          dateFieldStyle: themeData.dateFieldStyle.copyWith(
            iconStyle: themeData.dateFieldStyle.iconStyle.copyWith(
              color: themeData.colors.primary,
            ),
            textFieldStyle: themeData.dateFieldStyle.textFieldStyle
                .copyWith(
                  contentTextStyle: themeData.dateFieldStyle.textFieldStyle.contentTextStyle.map(
                    (style) => style.copyWith(
                      fontSize: themeData.typography.base.fontSize ?? style.fontSize,
                      color: themeData.colors.foreground,
                    ),
                  ),
                )
                .call,
          ),
        ),
        child: child!,
      ),
      initialRoute: kHomeRoute,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: [
        FLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routes: {
        kHomeRoute: (context) => const _MigratorWidget(
          child: HomeRouteScaffold(),
        ),
        kHistoryRoute: (context) => const HistoryRouteScaffold(),
      },
    );
  }

  /// The light and dark variants of a Teal theme.
  static final ({FThemeData light, FThemeData dark}) _tealTheme = (
    light: FThemeData(
      debugLabel: 'Teal Light ThemeData',
      colors: const FColors(
        brightness: Brightness.light,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        barrier: Color(0x33000000),
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF09090B),
        primary: Color(0xFF009688),
        primaryForeground: Color(0xFFF0FDFA),
        secondary: Color(0xFFF4F4F5),
        secondaryForeground: Color(0xFF18181B),
        muted: Color(0xFFF4F4F5),
        mutedForeground: Color(0xFF71717A),
        destructive: Color(0xFFEF4444),
        destructiveForeground: Color(0xFFFAFAFA),
        error: Color(0xFFEF4444),
        errorForeground: Color(0xFFFAFAFA),
        border: Color(0xFFE4E4E7),
      ),
    ),
    dark: FThemeData(
      debugLabel: 'Teal Dark ThemeData',
      colors: const FColors(
        brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        barrier: Color(0x7A000000),
        background: Color(0xFF0C0A09),
        foreground: Color(0xFFF2F2F2),
        primary: Color(0xFF0D9488),
        primaryForeground: Color(0xFF042F2E),
        secondary: Color(0xFF27272A),
        secondaryForeground: Color(0xFFF0FDFA),
        muted: Color(0xFF262626),
        mutedForeground: Color(0xFFA1A1AA),
        destructive: Color(0xFF7F1D1D),
        destructiveForeground: Color(0xFFFEF2F2),
        error: Color(0xFF7F1D1D),
        errorForeground: Color(0xFFFEF2F2),
        border: Color(0xFF27272A),
      ),
    ),
  );
}

/// Allows to use the [Migrator] class and to report changes to the user.
class _MigratorWidget extends ConsumerStatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new migrator widget instance.
  const _MigratorWidget({
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MigratorWidgetState();
}

/// The migrator widget state.
class _MigratorWidgetState extends ConsumerState<_MigratorWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Migrator.needsMigration(ref) && mounted) {
        showWaitingOverlay(
          context,
          future: Migrator.migrate(ref),
          message: translations.misc.migration,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
