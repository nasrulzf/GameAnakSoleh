# Game Anak Sholeh — Developer Documentation

Game edukasi Islami 2D ala platformer untuk anak usia 3–7 tahun, dibangun dengan Flutter + [Flame](https://flame-engine.org/) engine. Pemain menjelajahi level side-scrolling, melompati rintangan, dan menjawab soal-soal seputar pengetahuan Islam di setiap "quiz gate" untuk mencapai gerbang Madrasah di akhir level.

Dokumen ini adalah pintu masuk bagi developer baru (atau AI agent) yang akan melanjutkan pengembangan aplikasi ini. Baca sesuai kebutuhan:

| Dokumen | Isi |
|---|---|
| [architecture.md](architecture.md) | Struktur project, tumpukan teknologi, alur bootstrap, arsitektur game engine (Flame), state management, navigasi antar layar |
| [features.md](features.md) | Penjelasan tiap fitur yang sudah berjalan: sistem level & episode, karakter, quiz gate, heart/nyawa, skor & timer, audio, progres tersimpan |
| [content-authoring.md](content-authoring.md) | Panduan praktis menambah level baru dan menambah soal quiz baru, termasuk skema data lengkap |
| [roadmap.md](roadmap.md) | Rencana pengembangan project untuk beberapa fase ke depan |

## Ringkasan cepat

- **Platform**: Android saja (tidak ada target iOS/web — lihat `flutter_launcher_icons`/`flutter_native_splash` config di `pubspec.yaml`)
- **Engine**: Flutter 3.3+ dengan [Flame](https://pub.dev/packages/flame) `^1.18.0` sebagai game engine 2D
- **State management**: `provider` (`ChangeNotifierProvider`) — satu model global `GameProgress`
- **Persistensi**: `shared_preferences` (lokal, tanpa backend/network)
- **Status implementasi**: 20 dari 50 level yang direncanakan sudah dibangun (Episode 1 & 2 lengkap; Episode 3–5 belum dikerjakan). Lihat [roadmap.md](roadmap.md) untuk rencana lanjutannya.

## Dokumen lain yang relevan (di root project)

- `README.md` — pitch singkat aplikasi
- `requirement.md` — spesifikasi awal dari product owner
- `SETUP.md` — catatan setup environment build (Flutter/JDK/Android SDK, workaround bug Kotlin incremental di Windows). **Catatan: sebagian isinya sudah usang** (masih menyebut "2 level" dan "audio belum ada"), rujuk dokumen ini (docs/) untuk kondisi arsitektur terkini.
- `requirements/*/requirement.md` — spesifikasi per-fitur yang ditulis sebelum/selama implementasi (background pattern, popup soal, icon & splash, sound, 50-level scenario, dst). Berguna sebagai arsip keputusan desain, tapi sudah dirangkum dan diverifikasi ulang terhadap kode aktual di dokumen-dokumen docs/ ini.
