import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Karakter yang bisa dipilih pemain.
enum CharacterGender { boy, girl }

extension CharacterGenderLabel on CharacterGender {
  String get label => switch (this) {
        CharacterGender.boy => 'Anak Laki-laki',
        CharacterGender.girl => 'Anak Perempuan',
      };
}

const _prefsKeyGender = 'character_gender';
const _prefsKeyUnlockedLevel = 'unlocked_level';
const _prefsKeyBestScore = 'best_score';
const _prefsKeyPerfectLevels = 'perfect_levels';

/// Jumlah level per episode (lihat requirements/add-50-level-scenario) —
/// dipakai [GameProgress.isEpisodeClean] untuk menentukan rentang level satu
/// episode dari nomornya.
const kLevelsPerEpisode = 10;

Map<int, int> _decodeIntMap(SharedPreferences prefs, String key) {
  final raw = prefs.getString(key);
  if (raw == null) return {};
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
}

Map<int, bool> _decodeBoolMap(SharedPreferences prefs, String key) {
  final raw = prefs.getString(key);
  if (raw == null) return {};
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return decoded.map((k, v) => MapEntry(int.parse(k), v as bool));
}

/// State global aplikasi: karakter yang dipilih & progress level yang terbuka.
/// Dipersist ke shared_preferences supaya tidak hilang saat app ditutup.
class GameProgress extends ChangeNotifier {
  GameProgress._(
    this._prefs, {
    CharacterGender? gender,
    required int unlockedLevel,
    Map<int, int>? bestScore,
    Map<int, bool>? perfectLevels,
  })  : _gender = gender,
        _unlockedLevel = unlockedLevel,
        _bestScore = bestScore ?? {},
        _perfectLevels = perfectLevels ?? {};

  /// Instance kosong (belum baca SharedPreferences), dipakai sebagai value
  /// awal Provider di root app supaya widget tree sudah bisa dibangun
  /// sinkron sebelum [SplashScreen] menyelesaikan preload async lewat
  /// [hydrate] — lihat requirements/feature-game-icon/requirement.md.
  GameProgress.empty()
      : _prefs = null,
        _gender = null,
        _unlockedLevel = 1,
        _bestScore = {},
        _perfectLevels = {};

  static Future<GameProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final genderIndex = prefs.getInt(_prefsKeyGender);
    final gender = genderIndex == null ? null : CharacterGender.values[genderIndex];
    final unlockedLevel = prefs.getInt(_prefsKeyUnlockedLevel) ?? 1;
    return GameProgress._(
      prefs,
      gender: gender,
      unlockedLevel: unlockedLevel,
      bestScore: _decodeIntMap(prefs, _prefsKeyBestScore),
      perfectLevels: _decodeBoolMap(prefs, _prefsKeyPerfectLevels),
    );
  }

  SharedPreferences? _prefs;

  CharacterGender? _gender;
  CharacterGender? get gender => _gender;

  /// Level tertinggi yang sudah terbuka (1-based). Level 1 selalu terbuka.
  int _unlockedLevel;
  int get unlockedLevel => _unlockedLevel;

  /// Skor terbaik per level (levelId -> skor), dipersist permanen.
  final Map<int, int> _bestScore;
  Map<int, int> get bestScore => Map.unmodifiable(_bestScore);

  /// Status "Perfect" per level (selesai tanpa kehilangan heart sama
  /// sekali) — jadi syarat unlock episode spesial, lihat [isEpisodeClean].
  final Map<int, bool> _perfectLevels;
  Map<int, bool> get perfectLevels => Map.unmodifiable(_perfectLevels);

  /// Total skor tertinggi seluruh level yang pernah diselesaikan — dipakai
  /// Level Select untuk memotivasi pemain memecahkan rekornya sendiri.
  int get totalHighScore => _bestScore.values.fold(0, (a, b) => a + b);

  bool isLevelUnlocked(int level) {
    if (level > _unlockedLevel) return false;
    final episode = ((level - 1) ~/ kLevelsPerEpisode) + 1;
    // Episode spesial (4, 5, dst.) butuh 3 episode tepat sebelumnya bersih
    // (lihat requirements/add-50-level-scenario/requirement.md Bagian A) —
    // episode 1-3 tidak punya syarat tambahan ini.
    if (episode < 4) return true;
    return isSpecialEpisodeUnlocked(episode);
  }

  /// True bila seluruh [kLevelsPerEpisode] level di [episode] sudah pernah
  /// dicapai dengan status Perfect (lihat [_perfectLevels]).
  bool isEpisodeClean(int episode) {
    final firstLevel = (episode - 1) * kLevelsPerEpisode + 1;
    final lastLevel = episode * kLevelsPerEpisode;
    for (var level = firstLevel; level <= lastLevel; level++) {
      if (_perfectLevels[level] != true) return false;
    }
    return true;
  }

  /// True bila 3 episode tepat sebelum [episode] (N-3, N-2, N-1) semuanya
  /// bersih — aturan umum & berulang dipakai untuk Episode 4 & 5 (dan
  /// episode spesial berikutnya bila game diperluas melebihi 50 level).
  bool isSpecialEpisodeUnlocked(int episode) {
    return isEpisodeClean(episode - 3) &&
        isEpisodeClean(episode - 2) &&
        isEpisodeClean(episode - 1);
  }

  /// Mengisi instance (yang mungkin dibuat lewat [GameProgress.empty]) dengan
  /// data asli dari SharedPreferences. Dipanggil sekali oleh [SplashScreen]
  /// di awal alur preload, sebelum layar lain sempat memanggil [setGender]
  /// atau [completeLevel].
  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final genderIndex = prefs.getInt(_prefsKeyGender);
    _gender = genderIndex == null ? null : CharacterGender.values[genderIndex];
    _unlockedLevel = prefs.getInt(_prefsKeyUnlockedLevel) ?? 1;
    _bestScore
      ..clear()
      ..addAll(_decodeIntMap(prefs, _prefsKeyBestScore));
    _perfectLevels
      ..clear()
      ..addAll(_decodeBoolMap(prefs, _prefsKeyPerfectLevels));
    notifyListeners();
  }

  Future<void> setGender(CharacterGender gender) async {
    _gender = gender;
    notifyListeners();
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyGender, gender.index);
  }

  /// Dipanggil saat pemain menyelesaikan sebuah level. Membuka level berikutnya.
  Future<void> completeLevel(int level) async {
    final nextUnlock = level + 1;
    if (nextUnlock > _unlockedLevel) {
      _unlockedLevel = nextUnlock;
      notifyListeners();
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyUnlockedLevel, _unlockedLevel);
    }
  }

  /// Mencatat hasil satu attempt level: skor terbaik & status Perfect
  /// (lihat requirement Bagian B & C), dipersist permanen. Dipanggil
  /// terpisah dari [completeLevel] (kontrak method itu tidak berubah).
  Future<void> recordLevelResult(int levelId, int score, {required bool perfect}) async {
    final currentBest = _bestScore[levelId] ?? 0;
    final currentPerfect = _perfectLevels[levelId] ?? false;
    final newBest = score > currentBest ? score : currentBest;
    final newPerfect = currentPerfect || perfect;
    if (newBest == currentBest && newPerfect == currentPerfect) return;

    _bestScore[levelId] = newBest;
    _perfectLevels[levelId] = newPerfect;
    notifyListeners();

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyBestScore,
      jsonEncode(_bestScore.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setString(
      _prefsKeyPerfectLevels,
      jsonEncode(_perfectLevels.map((k, v) => MapEntry(k.toString(), v))),
    );
  }
}
