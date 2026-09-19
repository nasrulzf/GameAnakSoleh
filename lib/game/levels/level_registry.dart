import 'level_1.dart';
import 'level_10.dart';
import 'level_11.dart';
import 'level_12.dart';
import 'level_13.dart';
import 'level_14.dart';
import 'level_15.dart';
import 'level_16.dart';
import 'level_17.dart';
import 'level_18.dart';
import 'level_19.dart';
import 'level_2.dart';
import 'level_20.dart';
import 'level_3.dart';
import 'level_4.dart';
import 'level_5.dart';
import 'level_6.dart';
import 'level_7.dart';
import 'level_8.dart';
import 'level_9.dart';
import 'level_data.dart';

typedef LevelBuilder = LevelData Function();

/// Metadata ringan untuk satu level, dipakai [LevelSelectScreen] tanpa perlu
/// invoke builder-nya (builder melakukan random-pick soal, yang tidak perlu
/// terjadi hanya untuk menampilkan daftar).
class LevelMeta {
  const LevelMeta({
    required this.id,
    required this.episode,
    required this.title,
    required this.subtitle,
  });

  final int id;
  final int episode;
  final String title;
  final String subtitle;
}

/// ID level terakhir dari keseluruhan campaign (Grand Finale, lihat
/// requirements/add-50-level-scenario/requirement.md). Dipakai
/// GameplayScreen untuk membedakan AllLevelsCompleteScreen dari
/// LevelResultScreen biasa — SENGAJA berupa konstanta tetap, bukan
/// `kLevelBuilders.length`, supaya level terakhir yang baru
/// diimplementasikan (mis. Level 10 di Phase 1 ini) tidak salah memicu
/// layar finale sebelum seluruh 50 level selesai dibuat.
const kFinalLevelId = 50;

/// Judul tiap episode (Bagian A requirement), termasuk episode yang
/// levelnya belum diimplementasikan supaya UI Level Select tetap konsisten
/// saat fase berikutnya menyusul.
const kEpisodeTitles = <int, String>{
  1: 'Ngaji & Adab Harian',
  2: 'TPA & Belajar Al-Qur\'an',
  3: 'Masjid & Sholat Berjamaah',
  4: 'Ramadhan & Zakat',
  5: 'Haji, Kisah Nabi & Akhlak Mulia',
};

/// Registry level: satu-satunya sumber kebenaran untuk builder [LevelData]
/// per levelId, menggantikan ternary `widget.levelId == 1 ? ... : ...` yang
/// lama di GameplayScreen. Tambahkan entri baru di sini setiap kali
/// level_N.dart baru dibuat (Phase 2+).
final Map<int, LevelBuilder> kLevelBuilders = {
  1: buildLevel1,
  2: buildLevel2,
  3: buildLevel3,
  4: buildLevel4,
  5: buildLevel5,
  6: buildLevel6,
  7: buildLevel7,
  8: buildLevel8,
  9: buildLevel9,
  10: buildLevel10,
  11: buildLevel11,
  12: buildLevel12,
  13: buildLevel13,
  14: buildLevel14,
  15: buildLevel15,
  16: buildLevel16,
  17: buildLevel17,
  18: buildLevel18,
  19: buildLevel19,
  20: buildLevel20,
};

/// Metadata seluruh level yang sudah diimplementasikan, urut berdasarkan id.
const kLevelMeta = <LevelMeta>[
  LevelMeta(id: 1, episode: 1, title: 'Level 1', subtitle: 'Berangkat Ngaji'),
  LevelMeta(id: 2, episode: 1, title: 'Level 2', subtitle: 'Perjalanan ke TPA'),
  LevelMeta(id: 3, episode: 1, title: 'Level 3', subtitle: 'Adab di Jalan'),
  LevelMeta(id: 4, episode: 1, title: 'Level 4', subtitle: 'Menyebrang dengan Doa'),
  LevelMeta(id: 5, episode: 1, title: 'Level 5', subtitle: 'Bertemu Ustadz'),
  LevelMeta(id: 6, episode: 1, title: 'Level 6', subtitle: 'Belajar Wudhu Kecil'),
  LevelMeta(id: 7, episode: 1, title: 'Level 7', subtitle: 'Adab Makan Bersama'),
  LevelMeta(id: 8, episode: 1, title: 'Level 8', subtitle: 'Menolong Teman'),
  LevelMeta(id: 9, episode: 1, title: 'Level 9', subtitle: 'Pulang Sebelum Maghrib'),
  LevelMeta(id: 10, episode: 1, title: 'Level 10', subtitle: 'Ujian Ngaji Pertama'),
  LevelMeta(id: 11, episode: 2, title: 'Level 11', subtitle: 'Hari Pertama di TPA'),
  LevelMeta(id: 12, episode: 2, title: 'Level 12', subtitle: 'Mengenal Huruf Sambung'),
  LevelMeta(id: 13, episode: 2, title: 'Level 13', subtitle: 'Menaiki Tangga Ilmu'),
  LevelMeta(id: 14, episode: 2, title: 'Level 14', subtitle: 'Tanda Baca Al-Qur\'an'),
  LevelMeta(id: 15, episode: 2, title: 'Level 15', subtitle: 'Surat-Surat Pendek'),
  LevelMeta(id: 16, episode: 2, title: 'Level 16', subtitle: 'Mengenal Tajwid Dasar'),
  LevelMeta(id: 17, episode: 2, title: 'Level 17', subtitle: 'Melompati Rintangan Ilmu'),
  LevelMeta(id: 18, episode: 2, title: 'Level 18', subtitle: 'Adab Membaca Al-Qur\'an'),
  LevelMeta(id: 19, episode: 2, title: 'Level 19', subtitle: 'Lomba Hafalan Kecil'),
  LevelMeta(id: 20, episode: 2, title: 'Level 20', subtitle: 'Ujian Kenaikan TPA'),
];
