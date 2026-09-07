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
}
