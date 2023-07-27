import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history/history.dart';
import 'package:beerstory/model/migration/migrator.dart';
import 'package:beerstory/pages/bars.dart';
import 'package:beerstory/pages/beers.dart';
import 'package:beerstory/pages/history.dart';
import 'package:beerstory/pages/scaffold.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Hello world !
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Migrator.init();
  OpenFoodAPIConfiguration.userAgent = const UserAgent(
    name: 'Beerstory',
    url: 'https://github.com/Skyost/Beerstory',
  );
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH, OpenFoodFactsLanguage.FRENCH];
  runApp(ProviderScope(child: _BeerstoryApp()));
}

/// The beerstory app class.
class _BeerstoryApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BeerstoryAppState();
}

/// The beerstory app class state.
class _BeerstoryAppState extends ConsumerState<_BeerstoryApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Migrator.migrate(ref);
    });
  }

  @override
  Widget build(BuildContext context) => EzLocalizationBuilder(
    delegate: const EzLocalizationDelegate(
      supportedLocales: [
        Locale('en'),
        Locale('fr'),
      ],
    ),
    builder: (context, localizationDelegate) => MaterialApp(
      title: 'Beerstory',
      theme: ThemeData(
        useMaterial3: true,
        highlightColor: Colors.white12,
        scaffoldBackgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        canvasColor: Colors.grey[100],
        dialogTheme: const DialogTheme(
          surfaceTintColor: Colors.white,
        ),
        datePickerTheme: const DatePickerThemeData(
          surfaceTintColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          color: Colors.teal,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.teal,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.teal,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'BirdsOfParadise',
            fontSize: 34,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
      localeResolutionCallback: localizationDelegate.localeResolutionCallback,
      localizationsDelegates: localizationDelegate.localizationDelegates,
      supportedLocales: localizationDelegate.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => PageScaffold(
          pages: const [BeersPage(), BarsPage()],
        ),
        '/history': (context) => PageScaffold(
          pages: const [HistoryPage()],
        ),
      },
    ),
  );

  @override
  void dispose() {
    ref.read(barRepositoryProvider).dispose();
    ref.read(beerRepositoryProvider).dispose();
    ref.read(historyProvider).dispose();
    super.dispose();
  }
}
