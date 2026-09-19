# SFX placeholder (dari Mixkit)

6 file di folder ini adalah **placeholder sementara**, didownload dari
[Mixkit Free Sound Effects](https://mixkit.co/free-sound-effects/) (Mixkit
License — bebas dipakai untuk keperluan komersial/non-komersial, tanpa wajib
atribusi). Dipilih berdasarkan judul/kategori saja (belum divalidasi dengan
mendengarkan langsung oleh AI), jadi **wajib dicek manual** sebelum rilis —
terutama `answer_wrong.mp3` yang harus benar-benar terdengar lembut/tidak
menakutkan untuk anak 3-7 tahun (lihat acceptance criteria di requirement).

| File | Sumber Mixkit | Judul asli |
|---|---|---|
| `game_start.mp3` | sfx id 2984 | Funny melody audio logo |
| `jump.mp3` | sfx id 2043 | Player jumping in a video game |
| `quiz_trigger.mp3` | sfx id 2256 | Kids cartoon close bells |
| `answer_wrong.mp3` | sfx id 946 | Wrong answer fail notification |
| `answer_correct.mp3` | sfx id 952 | Correct answer reward |
| `level_complete.mp3` | sfx id 2059 | Game level completed |

Format masih `.mp3` (bukan `.ogg` seperti disarankan di requirement) karena
tidak ada `ffmpeg` untuk konversi saat file ini didownload — `flame_audio`
tetap bisa memutar `.mp3` langsung, jadi tidak masalah secara fungsional.

**Untuk hasil final yang konsisten & sesuai mood/tema game** (kalimba, frame
drum, warm & islami-anak), gunakan prompt AI audio-generation di
[requirements/sound-feature/requirement.md](../../../requirements/sound-feature/requirement.md)
untuk menggantikan file-file placeholder ini satu per satu (nama file boleh
tetap sama, atau ganti ke `.ogg` lalu update ekstensi di
`lib/audio/sound_service.dart`).
