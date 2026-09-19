import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Pembungkus pemutaran SFX untuk 6 momen yang diidentifikasi di
/// requirements/sound-feature/requirement.md. Nama file di sini harus sama
/// dengan "Nama file usulan" pada dokumen tersebut.
///
/// Aset audionya sendiri dihasilkan lewat AI audio-generation tool eksternal
/// (di luar scope kode ini) dan mungkin belum ada di `assets/sounds/sfx/` —
/// semua pemutaran dibungkus try/catch supaya game tetap berjalan normal
/// tanpa suara selama file belum digenerate.
class SoundService {
  SoundService._();

  static const gameStart = 'game_start.mp3';
  static const jump = 'jump.mp3';
  static const quizTrigger = 'quiz_trigger.mp3';
  static const answerWrong = 'answer_wrong.mp3';
  static const answerCorrect = 'answer_correct.mp3';
  static const levelComplete = 'level_complete.mp3';

  static const _allSfx = [
    gameStart,
    jump,
    quizTrigger,
    answerWrong,
    answerCorrect,
    levelComplete,
  ];

  static bool _preloadAttempted = false;

  /// Memuat semua SFX ke cache sekali di awal (dipanggil otomatis sebelum
  /// pemutaran pertama). Kegagalan (mis. file belum ada) diabaikan diam-diam.
  static Future<void> _ensurePreloaded() async {
    if (_preloadAttempted) return;
    _preloadAttempted = true;
    FlameAudio.audioCache.prefix = 'sounds/sfx/';
    try {
      await FlameAudio.audioCache.loadAll(_allSfx);
    } catch (error) {
      debugPrint('SoundService: gagal preload SFX ($error) — aset belum tersedia?');
    }
  }

  /// Memuat semua SFX ke cache secara eksplisit — dipanggil dari
  /// [SplashScreen] supaya sudah "hangat" sebelum gameplay pertama, alih-alih
  /// menunggu pemutaran suara pertama memicunya.
  static Future<void> preload() => _ensurePreloaded();

  static Future<void> _play(String fileName) async {
    await _ensurePreloaded();
    try {
      await FlameAudio.play(fileName);
    } catch (error) {
      debugPrint('SoundService: gagal memutar $fileName ($error)');
    }
  }

  static Future<void> playGameStart() => _play(gameStart);
  static Future<void> playJump() => _play(jump);
  static Future<void> playQuizTrigger() => _play(quizTrigger);
  static Future<void> playAnswerWrong() => _play(answerWrong);
  static Future<void> playAnswerCorrect() => _play(answerCorrect);
  static Future<void> playLevelComplete() => _play(levelComplete);
}
