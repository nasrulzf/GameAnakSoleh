import 'dart:math';

import 'quiz_question.dart';

/// Bank soal STARTER untuk usia 3-7 tahun.
///
/// PLACEHOLDER: ini adalah draft awal supaya sistem quiz bisa dibangun &
/// dites sekarang. Ganti/tambah soal di sini setelah soal resmi ditentukan
/// (lihat requirement.md).
class QuizBank {
  QuizBank._();

  static const List<QuizQuestion> all = [
    // Rukun Islam
    QuizQuestion(
      id: 'rukun_islam_1',
      category: QuizCategory.rukunIslam,
      question: 'Rukun Islam yang pertama adalah?',
      options: ['Syahadat', 'Puasa', 'Zakat', 'Haji'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_islam_2',
      category: QuizCategory.rukunIslam,
      question: 'Sholat wajib dikerjakan berapa kali sehari?',
      options: ['3 kali', '4 kali', '5 kali', '6 kali'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'rukun_islam_3',
      category: QuizCategory.rukunIslam,
      question: 'Bulan puasa umat Islam disebut bulan?',
      options: ['Syawal', 'Ramadhan', 'Rajab', 'Muharram'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'rukun_islam_4',
      category: QuizCategory.rukunIslam,
      question: 'Ibadah ke Mekkah disebut?',
      options: ['Zakat', 'Umroh', 'Haji', 'Qurban'],
      correctIndex: 2,
    ),

    // Rukun Iman (disederhanakan untuk anak)
    QuizQuestion(
      id: 'rukun_iman_1',
      category: QuizCategory.rukunIman,
      question: 'Kita wajib percaya bahwa Allah itu?',
      options: ['Ada', 'Tidak ada', 'Banyak', 'Kadang ada'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_iman_2',
      category: QuizCategory.rukunIman,
      question: 'Kitab suci umat Islam bernama?',
      options: ['Injil', 'Taurat', 'Al-Qur\'an', 'Zabur'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'rukun_iman_3',
      category: QuizCategory.rukunIman,
      question: 'Nabi terakhir yang diutus Allah adalah?',
      options: ['Nabi Musa', 'Nabi Muhammad', 'Nabi Isa', 'Nabi Adam'],
      correctIndex: 1,
    ),

    // Nama Nabi
    QuizQuestion(
      id: 'nama_nabi_1',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang selamat dari banjir besar dengan perahunya adalah?',
      options: ['Nabi Nuh', 'Nabi Yusuf', 'Nabi Ibrahim', 'Nabi Sulaiman'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_2',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang dikenal sangat sabar diuji dengan sakit lama adalah?',
      options: ['Nabi Ayyub', 'Nabi Yunus', 'Nabi Idris', 'Nabi Luth'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_3',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang ditelan ikan besar adalah?',
      options: ['Nabi Yunus', 'Nabi Nuh', 'Nabi Musa', 'Nabi Sholeh'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_4',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang membangun Ka\'bah bersama putranya adalah?',
      options: ['Nabi Ibrahim', 'Nabi Daud', 'Nabi Sulaiman', 'Nabi Zakaria'],
      correctIndex: 0,
    ),

    // Doa harian
    QuizQuestion(
      id: 'doa_harian_1',
      category: QuizCategory.doaHarian,
      question: 'Sebelum makan, sebaiknya kita membaca?',
      options: ['Doa sebelum makan', 'Doa naik kendaraan', 'Doa masuk masjid', 'Doa belajar'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_2',
      category: QuizCategory.doaHarian,
      question: 'Sebelum tidur malam, sebaiknya kita membaca?',
      options: ['Doa bercermin', 'Doa sebelum tidur', 'Doa naik kendaraan', 'Doa hujan'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'doa_harian_3',
      category: QuizCategory.doaHarian,
      question: 'Saat keluar rumah, sebaiknya kita membaca?',
      options: ['Doa keluar rumah', 'Doa bangun tidur', 'Doa sebelum makan', 'Doa untuk orang tua'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_4',
      category: QuizCategory.doaHarian,
      question: 'Setelah bangun tidur, sebaiknya kita membaca?',
      options: ['Doa bangun tidur', 'Doa sebelum tidur', 'Doa masuk kamar mandi', 'Doa naik kendaraan'],
      correctIndex: 0,
    ),

    // Huruf Hijaiyah dasar
    QuizQuestion(
      id: 'hijaiyah_1',
      category: QuizCategory.hijaiyah,
      question: 'Huruf hijaiyah pertama adalah?',
      options: ['Ba', 'Alif', 'Ta', 'Jim'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'hijaiyah_2',
      category: QuizCategory.hijaiyah,
      question: 'Setelah huruf Alif dan Ba, huruf berikutnya adalah?',
      options: ['Jim', 'Ta', 'Dal', 'Ha'],
      correctIndex: 1,
    ),

    // Malaikat
    QuizQuestion(
      id: 'malaikat_1',
      category: QuizCategory.malaikat,
      question: 'Malaikat yang bertugas menyampaikan wahyu adalah?',
      options: ['Jibril', 'Mikail', 'Israfil', 'Izrail'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'malaikat_2',
      category: QuizCategory.malaikat,
      question: 'Malaikat yang bertugas meniup sangkakala adalah?',
      options: ['Jibril', 'Munkar', 'Israfil', 'Ridwan'],
      correctIndex: 2,
    ),
  ];

  static List<QuizQuestion> byCategories(List<QuizCategory> categories) {
    return all.where((q) => categories.contains(q.category)).toList();
  }

  /// Ambil [count] soal acak dari [pool] tanpa pengulangan berlebihan, dipakai
  /// untuk mengisi quiz gate di dalam sebuah level.
  static List<QuizQuestion> randomPick(List<QuizQuestion> pool, int count, {Random? random}) {
    final rng = random ?? Random();
    final shuffled = List<QuizQuestion>.of(pool)..shuffle(rng);
    return shuffled.take(count).toList();
  }
}
