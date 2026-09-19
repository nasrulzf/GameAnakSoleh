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
      question: 'Di Bulan Apa kita wajib berpuasa selama 1 bulan penuh?',
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
      question: 'Rukun Iman itu ada berapa ?',
      options: ['6', '5', '4', '3'],
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

    // ============================================================
    // DRAFT — Episode 1 (Level 3-10): soal tambahan di bawah ini BELUM
    // final, perlu direview akurasi keagamaannya (mis. oleh ustadz/ustadzah)
    // sebelum dipakai anak-anak. Lihat
    // requirements/add-50-level-scenario/requirement.md Bagian G.
    // ============================================================

    // -- QuizCategory.adabHarian (baru, Episode 1) --
    QuizQuestion(
      id: 'adab_harian_ep1_01',
      category: QuizCategory.adabHarian,
      question: 'Sebelum berangkat dari rumah, sebaiknya kita mengucapkan?',
      options: ['Salam ke orang tua', 'Diam saja', 'Berteriak', 'Berlari cepat'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_02',
      category: QuizCategory.adabHarian,
      question: 'Nabi mencontohkan makan dengan menggunakan tangan ?',
      options: ['Kiri', 'Kanan', 'Keduanya', 'Tidak pakai tangan'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_03',
      category: QuizCategory.adabHarian,
      question: 'Ketika bertemu teman di jalan, sebaiknya kita?',
      options: ['Mengucapkan salam', 'Berpura-pura tidak lihat', 'Mengejeknya', 'Diam saja'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_04',
      category: QuizCategory.adabHarian,
      question: 'Saat menyebrang jalan, adab yang benar adalah?',
      options: [
        'Melihat kanan-kiri dulu',
        'Langsung berlari',
        'Sambil bermain HP',
        'Menutup mata',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_05',
      category: QuizCategory.adabHarian,
      question: 'Ketika bertemu dengan teman, sikap yang baik adalah ?',
      options: ['Mengucapkan salam', 'Berlari menjauh', 'Berteriak', 'Menutup wajah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_06',
      category: QuizCategory.adabHarian,
      question: 'Saat guru sedang mengajar, sebaiknya kita?',
      options: ['Mendengarkan dengan tenang', 'Ramai sendiri', 'Bermain-main', 'Keluar kelas'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_07',
      category: QuizCategory.adabHarian,
      question: 'Sebelum berwudhu, sebaiknya kita membaca?',
      options: ['Basmalah', 'Doa makan', 'Doa tidur', 'Tidak perlu apa-apa'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_08',
      category: QuizCategory.adabHarian,
      question: 'Air wudhu sebaiknya digunakan dengan cara?',
      options: ['Secukupnya, tidak boros', 'Sebanyak-banyaknya', 'Dibuang percuma', 'Tidak dipakai'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_09',
      category: QuizCategory.adabHarian,
      question: 'Sebelum makan bersama, kita sebaiknya membaca?',
      options: ['Basmalah', 'Salam', 'Takbir', 'Tidak perlu doa'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_10',
      category: QuizCategory.adabHarian,
      question: 'Makan dan minum yang baik sebaiknya menggunakan tangan?',
      options: ['Tangan kanan', 'Tangan kiri', 'Dua-duanya sekaligus', 'Tidak pakai tangan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_11',
      category: QuizCategory.adabHarian,
      question: 'Jika melihat teman kesulitan membawa barang, sebaiknya kita?',
      options: ['Menolongnya', 'Menertawakannya', 'Membiarkannya', 'Pergi menjauh'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_12',
      category: QuizCategory.adabHarian,
      question: 'Berbagi mainan atau makanan dengan teman termasuk perbuatan?',
      options: ['Baik dan terpuji', 'Buruk', 'Sia-sia', 'Tidak penting'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_13',
      category: QuizCategory.adabHarian,
      question: 'Sebaiknya seorang anak pulang ke rumah sebelum waktu?',
      options: ['Maghrib', 'Tengah malam', 'Subuh', 'Tidak perlu pulang'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_14',
      category: QuizCategory.adabHarian,
      question: 'Jika orang tua memanggil, sebaiknya kita?',
      options: ['Segera menjawab & menghampiri', 'Berpura-pura tidak dengar', 'Kabur', 'Diam saja'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_15',
      category: QuizCategory.adabHarian,
      question: 'Ketika diberi sesuatu oleh orang lain, kita mengucapkan?',
      options: ['Terima kasih / Jazakallah', 'Tidak perlu bicara', 'Mengeluh', 'Marah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_16',
      category: QuizCategory.adabHarian,
      question: 'Jika berbuat salah, sikap yang baik adalah?',
      options: ['Minta maaf', 'Menyalahkan orang lain', 'Berbohong', 'Kabur'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_17',
      category: QuizCategory.adabHarian,
      question: 'Berbicara dengan orang yang lebih tua sebaiknya dengan nada?',
      options: ['Sopan dan lembut', 'Kasar dan keras', 'Berteriak', 'Membentak'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'adab_harian_ep1_18',
      category: QuizCategory.adabHarian,
      question: 'Sebelum masuk rumah orang lain, sebaiknya kita?',
      options: ['Mengucapkan salam & minta izin', 'Langsung masuk', 'Mengetuk lalu kabur', 'Berteriak'],
      correctIndex: 0,
    ),

    // -- QuizCategory.doaHarian (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'doa_harian_ep1_05',
      category: QuizCategory.doaHarian,
      question: 'Saat masuk kamar mandi/WC, sebaiknya kita membaca?',
      options: ['Doa masuk kamar mandi', 'Doa sebelum makan', 'Doa naik kendaraan', 'Doa belajar'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_ep1_06',
      category: QuizCategory.doaHarian,
      question: 'Setelah selesai makan, sebaiknya kita membaca?',
      options: ['Doa setelah makan', 'Doa sebelum tidur', 'Doa keluar rumah', 'Doa bercermin'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_ep1_07',
      category: QuizCategory.doaHarian,
      question: 'Sebelum belajar, sebaiknya kita membaca?',
      options: ['Doa sebelum belajar', 'Doa naik kendaraan', 'Doa masuk masjid', 'Doa hujan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_ep1_08',
      category: QuizCategory.doaHarian,
      question: 'Ketika hendak naik kendaraan (mis. motor/mobil), sebaiknya membaca?',
      options: ['Doa naik kendaraan', 'Doa sebelum tidur', 'Doa masuk kamar mandi', 'Doa makan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_ep1_09',
      category: QuizCategory.doaHarian,
      question: 'Saat masuk masjid, sebaiknya kita membaca?',
      options: ['Doa masuk masjid', 'Doa keluar rumah', 'Doa bangun tidur', 'Doa belajar'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'doa_harian_ep1_10',
      category: QuizCategory.doaHarian,
      question: 'Untuk mendoakan kebaikan bagi ayah dan ibu, kita membaca?',
      options: ['Doa untuk orang tua', 'Doa naik kendaraan', 'Doa masuk kamar mandi', 'Doa hujan'],
      correctIndex: 0,
    ),

    // -- QuizCategory.rukunIslam (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'rukun_islam_ep1_05',
      category: QuizCategory.rukunIslam,
      question: 'Rukun Islam yang kedua adalah?',
      options: ['Sholat', 'Syahadat', 'Puasa', 'Haji'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_islam_ep1_06',
      category: QuizCategory.rukunIslam,
      question: 'Mengeluarkan sebagian harta untuk yang membutuhkan disebut?',
      options: ['Zakat', 'Sholat', 'Syahadat', 'Umroh'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_islam_ep1_07',
      category: QuizCategory.rukunIslam,
      question: 'Menahan makan dan minum dari pagi sampai maghrib disebut?',
      options: ['Puasa', 'Zakat', 'Sholat', 'Haji'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_islam_ep1_08',
      category: QuizCategory.rukunIslam,
      question: 'Rukun Islam ada berapa jumlahnya?',
      options: ['5', '3', '6', '4'],
      correctIndex: 0,
    ),

    // -- QuizCategory.rukunIman (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'rukun_iman_ep1_04',
      category: QuizCategory.rukunIman,
      question: 'Kita wajib percaya bahwa Allah mengutus para?',
      options: ['Rasul/Nabi', 'Raja', 'Presiden', 'Penyihir'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_iman_ep1_05',
      category: QuizCategory.rukunIman,
      question: 'Kita wajib percaya adanya hari akhir, yaitu hari?',
      options: ['Kiamat', 'Ulang tahun', 'Libur', 'Pasar'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_iman_ep1_06',
      category: QuizCategory.rukunIman,
      question: 'Kita wajib percaya bahwa Allah menciptakan makhluk gaib bernama?',
      options: ['Malaikat', 'Peri', 'Hantu', 'Robot'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'rukun_iman_ep1_07',
      category: QuizCategory.rukunIman,
      question: 'Rukun Iman ada berapa jumlahnya?',
      options: ['6', '4', '5', '7'],
      correctIndex: 0,
    ),

    // -- QuizCategory.hijaiyah (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'hijaiyah_ep1_03',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Ba"?',
      options: ['ا', 'ب', 'ت', 'ث'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep1_04',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Ta"?',
      options: ['ب', 'ث', 'ت', 'ج'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep1_05',
      category: QuizCategory.hijaiyah,
      question: 'Setelah huruf Ta, huruf berikutnya adalah?',
      options: ['Tsa', 'Jim', 'Ha', 'Dal'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep1_06',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Jim"?',
      options: ['ح', 'ج', 'خ', 'د'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep1_07',
      category: QuizCategory.hijaiyah,
      question: 'Setelah huruf Jim, huruf berikutnya adalah?',
      options: ['Kha', 'Dal', 'Ha', 'Ra'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep1_08',
      category: QuizCategory.hijaiyah,
      question: 'Huruf hijaiyah seluruhnya berjumlah?',
      options: ['20', '28', '30', '26'],
      correctIndex: 1,
    ),

    // -- QuizCategory.malaikat (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'malaikat_ep1_03',
      category: QuizCategory.malaikat,
      question: 'Malaikat yang bertugas mengatur rezeki/hujan adalah?',
      options: ['Mikail', 'Jibril', 'Israfil', 'Izrail'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'malaikat_ep1_04',
      category: QuizCategory.malaikat,
      question: 'Malaikat yang bertugas mencabut nyawa adalah?',
      options: ['Izrail', 'Jibril', 'Mikail', 'Ridwan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'malaikat_ep1_05',
      category: QuizCategory.malaikat,
      question: 'Malaikat penjaga pintu surga adalah?',
      options: ['Ridwan', 'Malik', 'Munkar', 'Nakir'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'malaikat_ep1_06',
      category: QuizCategory.malaikat,
      question: 'Malaikat yang kita imani jumlahnya ada berapa (yang wajib diketahui)?',
      options: ['10', '5', '8', '12'],
      correctIndex: 0,
    ),

    // -- QuizCategory.namaNabi (kategori lama, tambahan Episode 1) --
    QuizQuestion(
      id: 'nama_nabi_ep1_05',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang diberi kitab Taurat adalah?',
      options: ['Nabi Musa', 'Nabi Isa', 'Nabi Daud', 'Nabi Muhammad'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_ep1_06',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang diberi kitab Zabur adalah?',
      options: ['Nabi Daud', 'Nabi Musa', 'Nabi Isa', 'Nabi Nuh'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_ep1_07',
      category: QuizCategory.namaNabi,
      question: 'Nabi yang diberi kitab Injil adalah?',
      options: ['Nabi Isa', 'Nabi Musa', 'Nabi Daud', 'Nabi Sulaiman'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_nabi_ep1_08',
      category: QuizCategory.namaNabi,
      question: 'Nabi terakhir yang diberi kitab Al-Qur\'an adalah?',
      options: ['Nabi Muhammad', 'Nabi Musa', 'Nabi Isa', 'Nabi Ibrahim'],
      correctIndex: 0,
    ),

    // ============================================================
    // DRAFT — Episode 2 (Level 11-20): soal di bawah ini BELUM final, perlu
    // direview akurasi keagamaannya sebelum rilis. Lihat
    // requirements/add-50-level-scenario/requirement.md Bagian G.
    //
    // CATATAN KHUSUS `tajwidDasar`: sengaja dibatasi ke definisi paling
    // dasar & tidak kontroversial (apa itu tajwid, mad/bacaan panjang,
    // tanda waqaf, tartil). Hukum bacaan detail (idzhar/ikhfa/idgham/iqlab
    // dengan daftar huruf spesifik) SENGAJA TIDAK disertakan di fase ini
    // karena risiko kesalahan teknis lebih tinggi & butuh reviewer yang
    // benar-benar paham qiraah — bagian ini paling perlu diperiksa ulang.
    // ============================================================

    // -- QuizCategory.hijaiyah (kategori lama, tambahan Episode 2) --
    QuizQuestion(
      id: 'hijaiyah_ep2_09',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Dal"?',
      options: ['ح', 'خ', 'د', 'ذ'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep2_10',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Ra"?',
      options: ['ر', 'ز', 'د', 'و'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep2_11',
      category: QuizCategory.hijaiyah,
      question: 'Manakah huruf hijaiyah "Mim"?',
      options: ['ل', 'م', 'ن', 'ك'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'hijaiyah_ep2_12',
      category: QuizCategory.hijaiyah,
      question: 'Huruf hijaiyah terakhir (ke-28) adalah?',
      options: ['Ya', 'Wau', 'Hamzah', 'Lam'],
      correctIndex: 0,
    ),

    // -- QuizCategory.hijaiyahSambung --
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_01',
      category: QuizCategory.hijaiyahSambung,
      question: 'Saat disambung dengan huruf lain, bentuk huruf hijaiyah biasanya?',
      options: ['Berubah sedikit', 'Selalu sama persis', 'Menghilang', 'Berubah warna'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_02',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Alif" (ا) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Selalu wajib disambung',
        'Hanya bisa di awal kata',
        'Tidak pernah dipakai',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_03',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Dal" (د) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Selalu disambung ke semua arah',
        'Hanya huruf hijaiyah tunggal',
        'Berubah jadi huruf lain',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_04',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Wau" (و) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Wajib disambung ke depan & belakang',
        'Tidak termasuk huruf hijaiyah',
        'Hanya dipakai untuk harakat',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_05',
      category: QuizCategory.hijaiyahSambung,
      question: 'Kebanyakan huruf hijaiyah bisa disambung ke huruf...',
      options: ['Sebelum dan sesudahnya', 'Hanya sebelum', 'Hanya sesudah', 'Tidak bisa disambung sama sekali'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_06',
      category: QuizCategory.hijaiyahSambung,
      question: 'Belajar huruf sambung berguna supaya kita bisa membaca?',
      options: ['Tulisan Al-Qur\'an yang bersambung', 'Angka', 'Not musik', 'Peta'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_07',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Ra" (ر) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Selalu di tengah kata',
        'Bukan huruf hijaiyah',
        'Berubah jadi Zay',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_08',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Ba" (ب) di tengah kata biasanya ditulis...',
      options: ['Bersambung dengan huruf sebelum & sesudahnya', 'Terpisah sendiri', 'Terbalik', 'Tidak ditulis'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_09',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Dzal" (ذ) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Selalu di akhir ayat',
        'Tidak boleh dibaca',
        'Sama dengan huruf Dal dalam segala hal',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'hijaiyah_sambung_ep2_10',
      category: QuizCategory.hijaiyahSambung,
      question: 'Huruf "Zay" (ز) termasuk huruf yang...?',
      options: [
        'Tidak bisa disambung ke huruf sesudahnya',
        'Wajib disambung dua arah',
        'Bukan bagian dari 28 huruf hijaiyah',
        'Selalu diberi harakat sukun',
      ],
      correctIndex: 0,
    ),

    // -- QuizCategory.harakat --
    QuizQuestion(
      id: 'harakat_ep2_01',
      category: QuizCategory.harakat,
      question: 'Tanda baca yang membuat huruf berbunyi "a" disebut?',
      options: ['Fathah', 'Kasrah', 'Dhommah', 'Sukun'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'harakat_ep2_02',
      category: QuizCategory.harakat,
      question: 'Tanda baca yang membuat huruf berbunyi "i" disebut?',
      options: ['Fathah', 'Kasrah', 'Dhommah', 'Sukun'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'harakat_ep2_03',
      category: QuizCategory.harakat,
      question: 'Tanda baca yang membuat huruf berbunyi "u" disebut?',
      options: ['Fathah', 'Kasrah', 'Dhommah', 'Sukun'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'harakat_ep2_04',
      category: QuizCategory.harakat,
      question: 'Tanda baca yang membuat huruf tidak berbunyi (mati) disebut?',
      options: ['Fathah', 'Sukun', 'Kasrah', 'Dhommah'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'harakat_ep2_05',
      category: QuizCategory.harakat,
      question: 'Fathah biasanya digambar sebagai garis kecil di...',
      options: ['Atas huruf', 'Bawah huruf', 'Dalam huruf', 'Belakang huruf'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'harakat_ep2_06',
      category: QuizCategory.harakat,
      question: 'Kasrah biasanya digambar sebagai garis kecil di...',
      options: ['Atas huruf', 'Bawah huruf', 'Tengah huruf', 'Depan huruf'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'harakat_ep2_07',
      category: QuizCategory.harakat,
      question: 'Tanwin fathah (dua garis kecil di atas) berbunyi seperti?',
      options: ['...an', '...in', '...un', '...am'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'harakat_ep2_08',
      category: QuizCategory.harakat,
      question: 'Harakat dipakai untuk membantu kita membaca Al-Qur\'an dengan?',
      options: ['Benar sesuai bunyinya', 'Lebih cepat tanpa dipikir', 'Lebih pelan selalu', 'Terbalik-balik'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'harakat_ep2_09',
      category: QuizCategory.harakat,
      question: 'Sukun menandakan huruf tersebut dibaca...',
      options: ['Mati/tanpa vokal', 'Panjang sekali', 'Dua kali', 'Dengan dengungan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'harakat_ep2_10',
      category: QuizCategory.harakat,
      question: 'Tanwin dhommah (dua coretan kecil di atas huruf) berbunyi seperti?',
      options: ['...un', '...an', '...in', '...al'],
      correctIndex: 0,
    ),

    // -- QuizCategory.namaSurat --
    QuizQuestion(
      id: 'nama_surat_ep2_01',
      category: QuizCategory.namaSurat,
      question: 'Surat pertama dalam Al-Qur\'an adalah?',
      options: ['Al-Fatihah', 'Al-Baqarah', 'An-Nas', 'Al-Ikhlas'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_02',
      category: QuizCategory.namaSurat,
      question: 'Surat terakhir dalam Al-Qur\'an adalah?',
      options: ['An-Nas', 'Al-Fatihah', 'Al-Kautsar', 'Al-Falaq'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_03',
      category: QuizCategory.namaSurat,
      question: 'Surat yang menjelaskan tentang keesaan Allah adalah?',
      options: ['Al-Ikhlas', 'Al-Kautsar', 'Al-Fil', 'Al-Asr'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_04',
      category: QuizCategory.namaSurat,
      question: 'Surat Al-Falaq dan An-Nas biasa disebut dengan sebutan?',
      options: ['Al-Mu\'awwidzatain', 'Al-Mutsanna', 'Al-Mufassal', 'Al-Muqattaah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_05',
      category: QuizCategory.namaSurat,
      question: 'Surat Al-Kautsar berbicara tentang nikmat Allah yang?',
      options: ['Sangat banyak', 'Sangat sedikit', 'Tidak ada', 'Hilang'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_06',
      category: QuizCategory.namaSurat,
      question: 'Surat An-Nas berisi doa perlindungan dari?',
      options: ['Kejahatan bisikan setan', 'Hujan deras', 'Angin kencang', 'Gelapnya malam'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_07',
      category: QuizCategory.namaSurat,
      question: 'Surat Al-Falaq berisi doa perlindungan dari kejahatan di waktu?',
      options: ['Subuh (waktu fajar)', 'Siang bolong', 'Sore hari', 'Tengah malam saja'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_08',
      category: QuizCategory.namaSurat,
      question: 'Surat Al-Fatihah wajib dibaca setiap kali kita?',
      options: ['Sholat', 'Makan', 'Tidur', 'Bermain'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_09',
      category: QuizCategory.namaSurat,
      question: 'Al-Fatihah sering disebut juga Ummul Kitab, artinya?',
      options: ['Induk Al-Kitab', 'Anak Al-Kitab', 'Penutup Al-Kitab', 'Nama lain Al-Qur\'an'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_10',
      category: QuizCategory.namaSurat,
      question: 'Surat pendek yang sering dihafal anak-anak disebut surat-surat?',
      options: ['Juz Amma', 'Juz pertama', 'Juz tengah', 'Juz terpanjang'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_11',
      category: QuizCategory.namaSurat,
      question: 'Al-Ikhlas artinya kurang lebih?',
      options: ['Memurnikan (keesaan Allah)', 'Bantuan', 'Cahaya', 'Kemenangan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'nama_surat_ep2_12',
      category: QuizCategory.namaSurat,
      question: 'Sebelum membaca surat (selain At-Taubah), kita membaca?',
      options: ['Basmalah', 'Salam', 'Takbir', 'Tahlil'],
      correctIndex: 0,
    ),

    // -- QuizCategory.tajwidDasar (lihat catatan pembatasan di atas) --
    QuizQuestion(
      id: 'tajwid_dasar_ep2_01',
      category: QuizCategory.tajwidDasar,
      question: 'Ilmu yang mengajarkan cara membaca Al-Qur\'an dengan baik dan benar disebut?',
      options: ['Tajwid', 'Tafsir', 'Fiqih', 'Sejarah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_02',
      category: QuizCategory.tajwidDasar,
      question: 'Membaca Al-Qur\'an dengan pelan, jelas, dan sesuai kaidah disebut membaca secara?',
      options: ['Tartil', 'Tergesa-gesa', 'Asal-asalan', 'Berbisik'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_03',
      category: QuizCategory.tajwidDasar,
      question: 'Bacaan yang dipanjangkan dalam Al-Qur\'an disebut bacaan?',
      options: ['Mad', 'Waqaf', 'Ghunnah', 'Qalqalah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_04',
      category: QuizCategory.tajwidDasar,
      question: 'Tanda untuk berhenti membaca sejenak di Al-Qur\'an disebut tanda?',
      options: ['Waqaf', 'Mad', 'Sukun', 'Tasydid'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_05',
      category: QuizCategory.tajwidDasar,
      question: 'Belajar tajwid bertujuan supaya bacaan Al-Qur'
          '\'an kita menjadi?',
      options: ['Benar dan tidak salah arti', 'Lebih cepat selesai', 'Lebih keras suaranya', 'Lebih pendek'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_06',
      category: QuizCategory.tajwidDasar,
      question: 'Tanda kepala huruf "و" kecil di atas huruf yang menandakan bacaan panjang disebut tanda?',
      options: ['Mad', 'Waqaf', 'Sukun', 'Hamzah'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_07',
      category: QuizCategory.tajwidDasar,
      question: 'Sebelum belajar tajwid lebih lanjut, kita perlu lancar dulu membaca?',
      options: ['Huruf hijaiyah & harakat', 'Bahasa Inggris', 'Angka Romawi', 'Not balok'],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'tajwid_dasar_ep2_08',
      category: QuizCategory.tajwidDasar,
      question: 'Tasydid (tanda seperti huruf "w" kecil di atas huruf) menandakan huruf dibaca?',
      options: ['Ganda/double, lebih tebal', 'Dihilangkan', 'Sangat pelan', 'Terbalik'],
      correctIndex: 0,
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
