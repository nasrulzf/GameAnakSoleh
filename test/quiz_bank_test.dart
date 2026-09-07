import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/quiz/quiz_bank.dart';
import 'package:game_anak_soleh/quiz/quiz_question.dart';

void main() {
  group('QuizBank', () {
    test('setiap soal punya tepat 4 pilihan dan correctIndex valid', () {
      for (final q in QuizBank.all) {
        expect(q.options.length, 4, reason: 'Soal ${q.id} harus punya 4 pilihan');
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'Soal ${q.id}');
      }
    });

    test('setiap id unik', () {
      final ids = QuizBank.all.map((q) => q.id).toSet();
      expect(ids.length, QuizBank.all.length, reason: 'Ditemukan id soal duplikat');
    });

    test('byCategories hanya mengembalikan soal dari kategori yang diminta', () {
      final result = QuizBank.byCategories([QuizCategory.rukunIslam]);
      expect(result, isNotEmpty);
      expect(result.every((q) => q.category == QuizCategory.rukunIslam), isTrue);
    });

    test('randomPick mengembalikan jumlah soal yang diminta tanpa duplikat', () {
      final pool = QuizBank.byCategories([QuizCategory.namaNabi]);
      final picked = QuizBank.randomPick(pool, 3);
      expect(picked.length, 3);
      expect(picked.map((q) => q.id).toSet().length, 3);
    });

    test('isCorrect true hanya untuk correctIndex', () {
      final q = QuizBank.all.first;
      expect(q.isCorrect(q.correctIndex), isTrue);
      final wrongIndex = (q.correctIndex + 1) % 4;
      expect(q.isCorrect(wrongIndex), isFalse);
    });
  });
}
