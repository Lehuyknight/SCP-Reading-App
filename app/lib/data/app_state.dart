import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content_store.dart';
import 'models.dart';
import 'pack_service.dart';
import 'user_db.dart';

enum ReaderTheme { dark, sepia, light }

enum ReadFilter { all, unread, read }

class ReaderSettings {
  const ReaderSettings({
    this.fontSize = 17,
    this.lineHeight = 1.6,
    this.theme = ReaderTheme.dark,
    this.preferVietnamese = true,
  });

  final double fontSize;
  final double lineHeight;
  final ReaderTheme theme;
  final bool preferVietnamese;

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    ReaderTheme? theme,
    bool? preferVietnamese,
  }) =>
      ReaderSettings(
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        theme: theme ?? this.theme,
        preferVietnamese: preferVietnamese ?? this.preferVietnamese,
      );
}

class AppState extends ChangeNotifier {
  AppState._(this.content, this.packs, this._user, this._prefs, this._reading)
      : settings = ReaderSettings(
          fontSize: _prefs.getDouble('fontSize') ?? 17,
          lineHeight: _prefs.getDouble('lineHeight') ?? 1.6,
          theme: ReaderTheme.values[_prefs.getInt('readerTheme') ?? 0],
          preferVietnamese: _prefs.getBool('preferVietnamese') ?? true,
        ),
        appLocale = _prefs.getString('appLocale');

  final ContentStore content;
  final PackService packs;
  final UserDb _user;
  final SharedPreferences _prefs;
  final Map<String, ReadingState> _reading;
  ReaderSettings settings;

  /// `null` = theo ngôn ngữ hệ thống.
  String? appLocale;

  List<ScpSummary> all = const [];
  List<InstalledPack> installedPacks = const [];
  Map<String, ScpSummary> _byId = const {};
  bool hasTranslations = false;

  static Future<AppState> load() async {
    final content = await ContentStore.open();
    final packs = PackService(content);
    await packs.installBundledIfNeeded();
    final user = await UserDb.open();
    final prefs = await SharedPreferences.getInstance();
    final reading = await user.loadAll();
    final state = AppState._(content, packs, user, prefs, reading);
    await state._loadContent();
    return state;
  }

  Future<void> _loadContent() async {
    all = await content.allSummaries();
    installedPacks = await content.installedPacks();
    _byId = {for (final s in all) s.id: s};
    hasTranslations = all.any((s) => s.titleVi != null);
  }

  /// Gọi sau khi cài hoặc xóa gói nội dung.
  Future<void> reloadContent() async {
    await _loadContent();
    notifyListeners();
  }

  Future<void> setAppLocale(String? code) async {
    appLocale = code;
    notifyListeners();
    if (code == null) {
      await _prefs.remove('appLocale');
    } else {
      await _prefs.setString('appLocale', code);
    }
  }

  ScpSummary? byId(String id) => _byId[id];

  List<int> get availableSeries => (all.map((s) => s.series).toSet().toList()..sort());

  ReadingState stateOf(String id) => _reading[id] ?? ReadingState(scpId: id);

  bool isRead(String id) => _reading[id]?.isRead ?? false;

  List<ScpSummary> inSeries(int series, [ReadFilter filter = ReadFilter.all]) => all
      .where((s) => s.series == series)
      .where((s) => switch (filter) {
            ReadFilter.all => true,
            ReadFilter.read => isRead(s.id),
            ReadFilter.unread => !isRead(s.id),
          })
      .toList();

  int readCount([int? series]) => all
      .where((s) => series == null || s.series == series)
      .where((s) => isRead(s.id))
      .length;

  /// Các bài đã mở, mới nhất trước.
  List<(ScpSummary, ReadingState)> get history {
    final list = _reading.values
        .where((r) => r.lastOpenedAt != null && _byId.containsKey(r.scpId))
        .toList()
      ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
    return [for (final r in list) (_byId[r.scpId]!, r)];
  }

  /// Bài để "Đọc tiếp": bài mở gần nhất.
  (ScpSummary, ReadingState)? get continueReading {
    final h = history;
    return h.isEmpty ? null : h.first;
  }

  List<ScpSummary> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final digits = RegExp(r'\d+').firstMatch(q)?.group(0);
    return all.where((s) {
      if (digits != null && s.number.toString() == int.parse(digits).toString()) {
        return true;
      }
      return s.titleEn.toLowerCase().contains(q) ||
          (s.titleVi?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _put(ReadingState state) async {
    _reading[state.scpId] = state;
    notifyListeners();
    await _user.save(state);
  }

  Future<void> markOpened(String id) =>
      _put(stateOf(id).copyWith(lastOpenedAt: DateTime.now()));

  Future<void> saveScroll(String id, double ratio) {
    final current = stateOf(id);
    final shouldMarkRead = !current.isRead && ratio >= 0.9;
    return _put(current.copyWith(
      scrollRatio: ratio.clamp(0.0, 1.0),
      isRead: shouldMarkRead ? true : null,
    ));
  }

  Future<void> setRead(String id, bool read) => _put(stateOf(id).copyWith(isRead: read));

  Future<void> resetProgress() async {
    _reading.clear();
    await _user.clear();
    notifyListeners();
  }

  Future<void> updateSettings(ReaderSettings next) async {
    settings = next;
    notifyListeners();
    await _prefs.setDouble('fontSize', next.fontSize);
    await _prefs.setDouble('lineHeight', next.lineHeight);
    await _prefs.setInt('readerTheme', next.theme.index);
    await _prefs.setBool('preferVietnamese', next.preferVietnamese);
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
