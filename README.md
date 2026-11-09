# Cek Dulu

Pelindung penipuan online. Pengguna membagikan
tangkapan layar pesan mencurigakan, aplikasi membacanya **di ponsel**, lalu menampilkan
tingkat risiko, alasan singkat, dan langkah yang disarankan. Mode Lansia menambah tampilan
besar, penjelasan suara, dan tombol **Tanya keluarga**.

Konsep lengkap ada di `docs/KONSEP.md`. Desain Stitch (4 layar + DESIGN.md) ada di `docs/stitch/`.

## Menjalankan

Syarat: Flutter 3.24 atau lebih baru, Android SDK, ponsel atau emulator Android.

```bash
bash setup.sh     # flutter create (android saja), pub get, patch AndroidManifest
flutter run
flutter test      # tes mesin risiko
```

`setup.sh` hanya membuat folder `android/`; `lib/`, `test/`, `assets/`, dan `pubspec.yaml`
tidak ditimpa. Skrip `tool/patch_android.py` menambahkan menu **Bagikan** untuk gambar dan teks
(share target) serta `launchMode=singleTask` yang dibutuhkan paket `receive_sharing_intent`.

## Status verifikasi (jujur)

| Bagian | Status |
|---|---|
| Mesin risiko (`lib/engine/`) | Diuji di Dart 3.13.7: 15 tes lolos, `dart analyze` tanpa temuan (aturan flutter_lints belum diterapkan) |
| Kode UI Flutter (`lib/screens`, `widgets`, `services`, `core`) | Lolos `dart format` (sintaks benar). **Belum dikompilasi**: SDK Flutter tidak tersedia di lingkungan pembuatan |
| `tool/patch_android.py` | Diuji pada manifest bentuk templat Flutter, hasil XML valid, aman dijalankan ulang |
| Aplikasi di perangkat nyata | Belum dicoba |

Jadi anggap UI sebagai kerangka yang hampir pasti perlu perbaikan kecil saat pertama kali
`flutter run`. Versi paket di `pubspec.yaml` memakai tanda `^`; bila API paket berubah,
yang paling mungkin terdampak adalah `receive_sharing_intent` (`home_screen.dart`) dan
`google_mlkit_text_recognition` (`ocr_service.dart`).

## Struktur

```
lib/
  engine/     mesin penilaian risiko, murni Dart, tanpa Flutter
    risk_engine.dart       aturan, skor, batas tingkat
    entity_extractor.dart  rekening, telepon, URL, nama lembaga, penyamaran
    sign_defs.dart         teks tiap tanda (label, alasan, kalimat Mode Lansia)
    family_summary.dart    ringkasan termasker untuk pendamping
  core/       tema (DESIGN.md), state, penyimpanan lokal
  services/   OCR ML Kit, suara (TTS), WhatsApp keluarga, kanal lapor
  screens/    beranda, memeriksa, hasil (standar dan Mode Lansia)
  widgets/    komponen bersama, lembar pendamping keluarga
assets/fonts  Montserrat dan Plus Jakarta Sans (lisensi OFL, dibundel supaya offline)
test/         tes mesin risiko
docs/         konsep + ekspor Stitch
```

## Cara kerja penilaian

Aturan berbobot: tiap tanda yang terdeteksi menambah skor, lalu beberapa kombinasi
menaikkan skor minimum (misalnya hadiah + minta transfer, atau permintaan memasang APK).
Skor 60 ke atas = Risiko Tinggi, 30 sampai 59 = Perlu Hati-hati, di bawah itu = "Tidak
ditemukan tanda bahaya yang kami kenali".

Hal yang sengaja ditangani:
- Peringatan resmi bank ("jangan berikan kode OTP") **tidak** dianggap permintaan OTP.
- Layar masuk yang berisi "kode OTP telah dikirim" tidak ditandai.
- Notifikasi kurir dan promo dengan tautan ke domain resmi tidak ditandai.
- Nomor rekening hanya dihitung bila ada permintaan uang di sekitarnya; nomor resi tidak dianggap rekening.

Keterbatasan yang perlu dicatat di proposal: daftar domain resmi dan nama lembaga di
`entity_extractor.dart` hanya contoh kecil, aturan masih berbasis kata kunci (belum ada
klasifikasi TFLite), dan belum diukur pada tangkapan layar nyata. Jangan menulis klaim
akurasi sebelum ada pengujian pada data nyata dengan contoh "normal tapi mirip penipuan".

## Aturan penulisan (dari DESIGN.md)

Tidak ada teks UI yang menyatakan "aman" atau "pasti"; hasil rendah selalu berbunyi
"Tidak ditemukan tanda bahaya yang kami kenali"; setiap hasil diberi catatan "Hasil ini
indikasi, bukan putusan." Tes `aturan penulisan` di `test/risk_engine_test.dart` memeriksa
ini otomatis. Teks "dengan aman" pada layar Stitch sudah diganti ("Gambar diproses di
ponsel Anda"), dan "Ringkasan pesan aman" pada dialog Mode Lansia menjadi "Ringkasan pesan
sudah disiapkan".

## Privasi

- Gambar dibaca lewat ML Kit di perangkat, tidak diunggah, dan tidak disimpan. Riwayat hanya
  menyimpan hasil (tingkat, tanda, rekening yang sudah disamarkan), bukan gambar atau teks asli.
- Pendamping keluarga wajib disetujui eksplisit (kotak centang di lembar pengaturan).
- Ringkasan ke keluarga dikirim lewat WhatsApp dan pengguna menekan "kirim" sendiri. Isinya
  tidak memuat pesan asli.
- Tombol "Ini bukan penipuan" saat ini hanya mencatat di ponsel; belum ada pengiriman umpan
  balik ke server.

## Belum dikerjakan

- Pairing dan notifikasi push ke pendamping (Firebase/FCM + server kecil). Saat ini
  "Tanya keluarga" memakai WhatsApp, tanpa server dan tanpa biaya.
- Gelembung overlay dan ekstensi browser (tahap 2 di konsep).
- Klasifikasi teks TFLite, pembaruan aturan berkala, dan mekanisme laporan pengguna.
- Layar Stitch lain: onboarding dan persetujuan, hasil "Perlu Hati-hati" dan "tanpa tanda
  bahaya" versi desain, lapor terpandu, notifikasi pendamping. Kerangka hasil sudah
  menangani ketiga tingkat risiko, tetapi tampilannya belum didesain di Stitch.
- Verifikasi alamat kanal lapor di `lib/core/constants.dart` (`kIascUrl`), daftar domain resmi,
  dan butir bagian 14 pada konsep.
- Fonts: bila tim memilih Poppins, ganti file di `assets/fonts` dan nama family di
  `pubspec.yaml` serta `lib/core/theme.dart`.
"# cek_dulu" 
