/// Kategori materi keislaman untuk soal, dipakai untuk mengelompokkan bank soal.
enum QuizCategory {
  rukunIslam,
  rukunIman,
  doaHarian,
  namaNabi,
  hijaiyah,
  malaikat,
}

/// Satu soal pilihan ganda untuk quiz gate di dalam level.
class QuizQuestion {
  // Catatan: validasi "options harus punya 4 pilihan" tidak bisa ditulis di
  // sini sebagai assert const (List.length bukan constant expression yang
  // valid di Dart), jadi divalidasi lewat test/quiz_bank_test.dart.
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
  }) : assert(correctIndex >= 0 && correctIndex < 4, 'correctIndex harus 0-3');

  final String id;
  final QuizCategory category;
  final String question;
  final List<String> options;
  final int correctIndex;

  String get correctAnswer => options[correctIndex];

  bool isCorrect(int chosenIndex) => chosenIndex == correctIndex;
}
