# Setup & Menjalankan Project

## Status di komputer ini — sudah terverifikasi end-to-end

- Flutter SDK 3.47.2 di `D:\Installation\flutter`, JDK 17 (Temurin) di
  `D:\Installation\jdk17`, Android SDK (platform-tools, platform 34 & 36,
  build-tools 28.0.3/34/36, NDK) di `D:\Installation\Android\sdk` — semua
  sudah terpasang, env var (`JAVA_HOME`, `ANDROID_HOME`, `PATH`) sudah diset
  permanen di level user.
- `flutter analyze` → 0 issues.
- `flutter test` → 10/10 test lolos (`quiz_bank_test.dart`,
  `game_progress_test.dart`, `widget_test.dart`).
- `flutter build apk --debug` → **berhasil**, menghasilkan
  `build\app\outputs\flutter-apk\app-debug.apk` (~154 MB, belum di-shrink
  karena build debug). Ini membuktikan seluruh pipeline (kode Dart/Flame kita
  + Gradle + Kotlin + Android SDK) benar-benar bisa dikompilasi jadi APK,
  bukan cuma lolos review statis.

### Catatan bug lingkungan yang sudah diperbaiki

Build pertama gagal karena bug Kotlin incremental compiler di Windows: cache-nya
crash saat project ada di drive `D:` sementara dependency Pub cache ada di
drive `C:` (tidak bisa hitung relative path lintas drive). Ini bug tooling,
bukan bug kode kita. Sudah di-workaround dengan menambahkan
`kotlin.incremental=false` di `android/gradle.properties` (rebuild jadi
sedikit lebih lambat, tapi build selalu berhasil). Kalau nanti Anda pindahkan
project ke drive yang sama dengan Pub cache (biasanya `C:\Users\<user>\AppData\Local\Pub\Cache`),
baris itu boleh dihapus.

### Sudah ditest di emulator Android (Pixel 5, Android 14) — 3 bug ditemukan & diperbaiki

Dibuat AVD `GameAnakSoleh_Test` (data di `D:\Installation\android-avd` — AVD
default di `C:` kehabisan ruang), dijalankan headless, lalu di-install & di-drive
lewat `adb`. Ditemukan & sudah diperbaiki:

1. **Layout overflow "BOTTOM OVERFLOWED"** di Main Menu, Character Select, dan
   Level Result saat layar landscape pendek (device fisik akan lebih pendek
   dari emulator ini) — konten `Column` tidak scrollable. Fix: bungkus dengan
   `LayoutBuilder` + `SingleChildScrollView` (`lib/ui/main_menu_screen.dart`,
   `character_select_screen.dart`, `level_result_screen.dart`).
2. **Preview karakter di Character Select tidak tergambar** (cuma garis
   tipis) — `CustomPaint` tidak punya lebar eksplisit sehingga di-render
   dengan width≈0. Fix: tambah `width: double.infinity` di
   `character_select_screen.dart`.
3. **Crash `LateInitializationError: Field 'player' has not been
   initialized'`** saat masuk ke layar gameplay — tombol lompat di HUD
   mengakses `game.player` secara langsung saat `build()`, padahal `player`
   baru diisi di dalam `onLoad()` milik Flame yang async. Fix: bungkus jadi
   closure `() => game.player.requestJump()` di `lib/game/hud_overlay.dart`.

Setelah ketiga fix ini: Main Menu → Character Select (preview render benar,
render karakter sesuai deskripsi peci/kerudung) → Level Select (Level 1
terbuka, Level 2 terkunci) → Gameplay Level 1 (karakter, ground, HUD, kontrol
gerak, dan collision block terhadap rintangan) semua terverifikasi jalan
tanpa crash/overflow. `flutter analyze` tetap 0 issues dan `flutter test`
tetap 10/10 setelah semua fix ini.

Catatan: emulator headless (software rendering SwiftShader, tanpa GPU host)
ini sering memunculkan dialog "System UI isn't responding" / "Process system
isn't responding" — itu proses sistem Android bawaan emulator yang kepayahan
CPU, **bukan** masalah dari app kita (device fisik Samsung A15/Tab A9 dengan
GPU asli tidak akan mengalami ini).

## Menjalankan di device fisik (Samsung A15 / Galaxy Tab A9 8")

Sambungkan device via USB (aktifkan USB debugging), lalu dari root project:

```bash
flutter devices        # pastikan device terdeteksi
flutter run
```

Atau install APK yang sudah dibuild manual:

```bash
adb install build\app\outputs\flutter-apk\app-debug.apk
```

Untuk rilis (APK lebih kecil, minified):

```bash
flutter build apk --release
```

## Jalankan ulang analyze/test/build kapan saja

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Status implementasi saat ini

- Karakter: anak laki-laki (peci) & anak perempuan (kerudung/jilbab),
  keduanya seragam SD + tas, memakai sprite hasil potong dari
  `requirements/character-enhancements/assets/character.jpeg`
  (lihat `assets/images/characters/` & `lib/game/components/player_component.dart`).
- Level 1 ("Berangkat Ngaji") & Level 2 ("Perjalanan ke TPA"): gerak,
  lompat, rintangan, dan **quiz gate** (gerbang yang wajib dijawab benar
  untuk lewat, tanpa penalti kalau salah — ramah untuk usia 3-7 tahun).
- Soal keislaman: bank soal starter ~18 soal di `lib/quiz/quiz_bank.dart`,
  ditandai sebagai **placeholder** — silakan diganti/ditambah setelah
  soal resmi ditentukan (lihat `requirement.md`).
- Progress (karakter & level terbuka) disimpan lokal via `shared_preferences`.
- Kontrol: tombol sentuh di layar (kiri/kanan/lompat), plus dukungan
  keyboard (panah/WASD/spasi) untuk memudahkan testing di desktop.

## Yang belum dikerjakan / langkah lanjutan

- Testing langsung di Samsung A15 / Galaxy Tab A9 (belum ada device fisik
  tersambung di sesi ini) — jalankan `flutter run` setelah device terhubung.
- Asset grafis asli (sprite pixel-art, background, tile) — saat ini masih
  bentuk geometris programatik.
- Audio (musik, efek suara, narasi soal — penting untuk usia pra-baca).
- Level 3 dan seterusnya.
- Layar splash/App icon (`android/app/src/main/res/...`) — masih default
  bawaan `flutter create`.
