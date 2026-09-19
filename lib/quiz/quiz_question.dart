/// Kategori materi keislaman untuk soal, dipakai untuk mengelompokkan bank soal.
///
/// Kategori Episode 2-5 (`hijaiyahSambung` s/d `akhlakMulia`) sudah
/// didaftarkan sekarang sesuai template Bagian G di
/// requirements/add-50-level-scenario/requirement.md supaya enum tidak perlu
/// dimigrasi berulang tiap episode baru dikerjakan — bank soalnya sendiri
/// baru diisi bertahap per fase (lihat quiz_bank.dart).
enum QuizCategory {
  // --- kategori existing ---
  rukunIslam,
  rukunIman,
  doaHarian,
  namaNabi,
  hijaiyah,
  malaikat,

  // --- kategori baru (Episode 1) ---
  adabHarian,

  // --- kategori baru (Episode 2) ---
  hijaiyahSambung,
  harakat,
  namaSurat,
  tajwidDasar,

  // --- kategori baru (Episode 3) ---
  rukunSholat,
  wudhu,
  adzanIqamah,

  // --- kategori baru (Episode 4) ---
  ramadhanPuasa,
  zakatSedekah,

  // --- kategori baru (Episode 5) ---
  hajiUmroh,
  kisahNabiLanjutan,
  asmaulHusna,
  akhlakMulia,
}

/// Tingkat kesulitan soal, dipakai untuk menyeimbangkan campuran soal di
/// level boss/finale. Default `mudah` supaya soal-soal lama tetap valid
/// tanpa perlu diubah.
enum QuizDifficulty { mudah, sedang, sulit }

/// Satu soal pilihan ganda untuk quiz gate di dalam level.
///
/// [question] dan [options] boleh berisi huruf hijaiyah/Arab langsung
/// sebagai string biasa (Unicode Arab didukung otomatis) — lihat
/// requirements/add-50-level-scenario/requirement.md Bagian E untuk catatan
/// font fallback yang dibutuhkan di sisi UI (`QuizOverlay`).
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
    this.difficulty = QuizDifficulty.mudah,
  }) : assert(correctIndex >= 0 && correctIndex < 4, 'correctIndex harus 0-3');

  final String id;
  final QuizCategory category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final QuizDifficulty difficulty;

  String get correctAnswer => options[correctIndex];

  bool isCorrect(int chosenIndex) => chosenIndex == correctIndex;
}
