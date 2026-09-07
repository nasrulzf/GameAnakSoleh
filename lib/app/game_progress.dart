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

/// State global aplikasi: karakter yang dipilih & progress level yang terbuka.
/// Dipersist ke shared_preferences supaya tidak hilang saat app ditutup.
class GameProgress extends ChangeNotifier {
  GameProgress._(this._prefs, {CharacterGender? gender, required int unlockedLevel})
      : _gender = gender,
        _unlockedLevel = unlockedLevel;

  static Future<GameProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final genderIndex = prefs.getInt(_prefsKeyGender);
    final gender = genderIndex == null ? null : CharacterGender.values[genderIndex];
    final unlockedLevel = prefs.getInt(_prefsKeyUnlockedLevel) ?? 1;
    return GameProgress._(prefs, gender: gender, unlockedLevel: unlockedLevel);
  }

  final SharedPreferences _prefs;

  CharacterGender? _gender;
  CharacterGender? get gender => _gender;

  /// Level tertinggi yang sudah terbuka (1-based). Level 1 selalu terbuka.
  int _unlockedLevel;
  int get unlockedLevel => _unlockedLevel;

  bool isLevelUnlocked(int level) => level <= _unlockedLevel;

  Future<void> setGender(CharacterGender gender) async {
    _gender = gender;
    notifyListeners();
    await _prefs.setInt(_prefsKeyGender, gender.index);
  }

  /// Dipanggil saat pemain menyelesaikan sebuah level. Membuka level berikutnya.
  Future<void> completeLevel(int level) async {
    final nextUnlock = level + 1;
    if (nextUnlock > _unlockedLevel) {
      _unlockedLevel = nextUnlock;
      notifyListeners();
      await _prefs.setInt(_prefsKeyUnlockedLevel, _unlockedLevel);
    }
  }
}
