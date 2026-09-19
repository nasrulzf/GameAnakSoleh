import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/app/game_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('level 1 selalu terbuka secara default', () async {
    final progress = await GameProgress.load();
    expect(progress.isLevelUnlocked(1), isTrue);
    expect(progress.isLevelUnlocked(2), isFalse);
  });

  test('setGender menyimpan pilihan karakter dan dipersist', () async {
    final progress = await GameProgress.load();
    await progress.setGender(CharacterGender.girl);
    expect(progress.gender, CharacterGender.girl);

    final reloaded = await GameProgress.load();
    expect(reloaded.gender, CharacterGender.girl);
  });

  test('completeLevel membuka level berikutnya dan dipersist', () async {
    final progress = await GameProgress.load();
    expect(progress.isLevelUnlocked(2), isFalse);

    await progress.completeLevel(1);
    expect(progress.isLevelUnlocked(2), isTrue);

    final reloaded = await GameProgress.load();
    expect(reloaded.isLevelUnlocked(2), isTrue);
  });

  test('completeLevel tidak menurunkan level yang sudah terbuka', () async {
    final progress = await GameProgress.load();
    await progress.completeLevel(1);
    await progress.completeLevel(1);
    expect(progress.unlockedLevel, 2);
  });

  test('recordLevelResult menyimpan skor terbaik & status perfect, dipersist', () async {
    final progress = await GameProgress.load();
    await progress.recordLevelResult(1, 150, perfect: false);
    expect(progress.bestScore[1], 150);
    expect(progress.perfectLevels[1], isFalse);

    // Skor lebih rendah tidak menurunkan best score.
    await progress.recordLevelResult(1, 100, perfect: true);
    expect(progress.bestScore[1], 150);
    expect(progress.perfectLevels[1], isTrue);

    // Skor lebih tinggi menaikkan best score.
    await progress.recordLevelResult(1, 200, perfect: false);
    expect(progress.bestScore[1], 200);
    expect(progress.perfectLevels[1], isTrue); // tetap true walau attempt ini tidak perfect

    final reloaded = await GameProgress.load();
    expect(reloaded.bestScore[1], 200);
    expect(reloaded.perfectLevels[1], isTrue);
    expect(reloaded.totalHighScore, 200);
  });

  test('isEpisodeClean & isSpecialEpisodeUnlocked mengikuti window 3 episode berturut-turut', () async {
    final progress = await GameProgress.load();
    expect(progress.isEpisodeClean(1), isFalse);

    for (var level = 1; level <= 30; level++) {
      await progress.recordLevelResult(level, 100, perfect: true);
    }
    expect(progress.isEpisodeClean(1), isTrue);
    expect(progress.isEpisodeClean(2), isTrue);
    expect(progress.isEpisodeClean(3), isTrue);
    expect(progress.isSpecialEpisodeUnlocked(4), isTrue);
    expect(progress.isSpecialEpisodeUnlocked(5), isFalse);

    for (var level = 31; level <= 40; level++) {
      await progress.recordLevelResult(level, 100, perfect: true);
    }
    expect(progress.isSpecialEpisodeUnlocked(5), isTrue);
  });
}
