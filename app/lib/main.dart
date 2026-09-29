import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_state.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScpReaderApp());
}

class ScpReaderApp extends StatefulWidget {
  const ScpReaderApp({super.key});

  @override
  State<ScpReaderApp> createState() => _ScpReaderAppState();
}

class _ScpReaderAppState extends State<ScpReaderApp> {
  late final Future<AppState> _loading = AppState.load();

  MaterialApp _app(Widget home, {String? locale}) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: locale == null ? null : Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _app(Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.of(context).loadError('${snapshot.error}'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ));
        }
        if (!snapshot.hasData) {
          return _app(const Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        // AppScope phải bọc ngoài MaterialApp để các route được push (trang Đọc) cũng truy cập được.
        return AppScope(
          state: snapshot.data!,
          child: Builder(
            builder: (context) =>
                _app(const HomeShell(), locale: AppScope.of(context).appLocale),
          ),
        );
      },
    );
  }
}
