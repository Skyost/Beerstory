import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/pages/routes.dart';
import 'package:beerstory/pages/scaffold.dart';
import 'package:beerstory/utils/brightness_listener.dart';
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

/// The Beerstory app main class.
class _BeerstoryApp extends ConsumerStatefulWidget {
  /// The light and dark variants of a Teal theme.
  static final ({FThemeData light, FThemeData dark}) tealTheme = (
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

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BeerstoryAppState();
}

/// The Beerstory app state.
class _BeerstoryAppState extends ConsumerState<_BeerstoryApp> with BrightnessListener<_BeerstoryApp> {
  @override
  Widget build(BuildContext context) {
    FThemeData themeData = currentBrightness == Brightness.dark ? _BeerstoryApp.tealTheme.dark : _BeerstoryApp.tealTheme.light;
    return MaterialApp(
      title: 'Beerstory',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: themeData.copyWith(
          headerStyles: (headerStyles) => headerStyles.copyWith(
            rootStyle: (rootStyle) => rootStyle.copyWith(
              titleTextStyle: rootStyle.titleTextStyle.copyWith(
                fontFamily: 'BirdsOfParadise',
                height: 1.15,
              ),
            ),
            nestedStyle: (nestedStyle) => nestedStyle.copyWith(
              titleTextStyle: nestedStyle.titleTextStyle.copyWith(
                fontFamily: 'BirdsOfParadise',
                fontSize: 24,
                height: 1.15,
              ),
            ),
          ),
          textFieldStyle: (textFieldStyle) => textFieldStyle.copyWith(
            contentTextStyle: textFieldStyle.contentTextStyle.map(
              (style) => style.copyWith(
                color: themeData.colors.foreground,
              ),
            ),
          ),
          dateFieldStyle: (dateFieldStyle) => dateFieldStyle.copyWith(
            iconStyle: dateFieldStyle.iconStyle.copyWith(
              color: themeData.colors.primary,
            ),
            textFieldStyle: (textFieldStyle) => textFieldStyle.copyWith(
              contentTextStyle: textFieldStyle.contentTextStyle.map(
                (style) => style.copyWith(
                  fontSize: themeData.typography.base.fontSize ?? style.fontSize,
                  color: themeData.colors.foreground,
                ),
              ),
            ),
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
        kHomeRoute: (context) => const HomeRouteScaffold(),
        kHistoryRoute: (context) => const HistoryRouteScaffold(),
        kSettingsRoute: (context) => const SettingsRouteScaffold(),
      },
    );
  }
}
