# Konsep Proyek: Pelindung Penipuan Online (Pindai Tangkapan Layar + Pendamping Lansia)

**Kompetisi:** ADIKARA 2026 — Kompetisi Inovasi, subdivisi Software (Fakultas Informatika Telkom University)
**Sub-tema:** "Shaping a Resilient Future through Digital Transformation"
**Keterkaitan SDG/Asta Cita yang disasar lomba:** SDG 3, 4, 7, 8, 9, 11; Asta Cita 2, 4, 6 (pilih yang paling relevan setelah konsep dikunci; kandidat awal: SDG 16 tidak termasuk daftar lomba, jadi petakan ke SDG 9 dan 11 serta Asta Cita yang sesuai setelah dicek ke panduan resmi)
**Status dokumen:** draf kerja v2 (diperbarui 9 Nov 2026). Tenggat lomba dan jumlah anggota tim: **belum diketahui (isi di bagian 13)**. Status pengerjaan proposal, desain, dan sisa tugas ada di **Lampiran C**.

> Penanda: **[Terverifikasi]** = didukung sumber yang ditemukan saat riset. **[Belum diverifikasi]** = perlu dicek sebelum masuk proposal.

---

## 1. Ringkasan satu kalimat

Aplikasi yang menerima tangkapan layar (lewat tombol "Bagikan" dari WhatsApp, galeri, atau browser), menilai risiko penipuannya dengan penjelasan sederhana, dan untuk lansia otomatis melibatkan keluarga yang ditunjuk sebelum uang berpindah.

Nama kerja produk: *[belum ditentukan]*. Ide awal: "Cek Dulu", "Tanya Dulu", "Jaga Keluarga".

## 2. Latar belakang masalah

- **[Terverifikasi]** Indonesia Anti-Scam Centre (IASC) milik OJK mencatat total kerugian dari laporan masyarakat sebesar Rp 9,1 triliun dengan 432.637 laporan sejak berdiri (22 Nov 2024) sampai pertengahan Januari 2026.
- **[Terverifikasi]** Modus terbanyak per Januari 2026: penipuan transaksi belanja (73.743 laporan) dan impersonation/fake call (44.446 laporan), disusul lowongan kerja (23.469) dan media sosial (19.983).
- **[Terverifikasi]** Jawa Barat tercatat sebagai provinsi dengan laporan scam tertinggi: 131.445 laporan dari Nov 2024 sampai Juni 2026 (nasional: 637.055 laporan).
- **[Belum diverifikasi]** Klaim bahwa korban banyak berasal dari kalangan mahasiswa dan lansia. Cari rincian profil/usia korban dari OJK atau sumber resmi lain sebelum menuliskannya.

Catatan: angka di atas adalah laporan sektor keuangan ke IASC, bukan total seluruh penipuan online.

## 3. Solusi yang sudah ada dan celahnya

| Layanan | Fungsi | Keterbatasan |
|---|---|---|
| IASC (OJK) | Menerima laporan, memblokir rekening terindikasi | Reaktif, setelah ada korban/laporan |
| CekRekening.id | Memeriksa rekening/e-wallet yang pernah dilaporkan | Hanya mengenali yang sudah dilaporkan |
| Kredibel | Rekam jejak rekening dan nomor telepon | Sama; tidak menjamin aman |

**Celah yang diisi proyek ini:** analisis **isi dan konteks** pesan/halaman (apa yang ditawarkan, bagaimana bahasanya menekan korban, apakah meniru pihak resmi), dijelaskan dalam bahasa awam, ditambah **alur keluarga** untuk lansia. Rekening penipu baru yang belum pernah dilaporkan akan lolos dari pengecekan berbasis daftar, tetapi pola isi pesannya masih bisa dikenali.

## 4. Konsep produk

### 4.1 Alur pengguna inti

1. Pengguna menerima pesan atau melihat iklan yang mencurigakan, menekan **Bagikan**, lalu memilih aplikasi.
2. Sistem membaca isi gambar **di perangkat** dan menampilkan: tingkat risiko, alasan singkat (2–3 kalimat), dan langkah yang disarankan (jangan transfer, jangan beri OTP, hubungi pihak resmi, lapor).
3. **Mode lansia:** tampilan besar, bahasa sangat sederhana, penjelasan lewat suara, dan satu tombol **"Tanya keluarga"** yang mengirim ringkasan ke pendamping.
4. Pendamping menerima notifikasi dan bisa membalas cepat.

### 4.2 Modul

| Modul | Isi | Prioritas |
|---|---|---|
| Pemindai tangkapan layar | OCR, ekstraksi rekening/telepon/URL/nama organisasi, deteksi pola bujukan | MVP |
| Mesin penilaian risiko | Aturan + klasifikasi teks + pengecekan silang ke sumber publik | MVP |
| Pendamping keluarga | Pairing dengan persetujuan lansia, notifikasi ringkas, balasan cepat | MVP |
| Lapor terpandu | Mengarahkan dan melengkapi laporan ke kanal resmi (IASC) | MVP |
| Gelembung overlay mengambang | Tombol mengambang ala Google Lens di atas aplikasi apa pun; diketuk → tangkap layar (MediaProjection) → mesin yang sama → kartu hasil ringkas. Hanya memeriksa saat diketuk | Tahap 2 |
| Ekstensi browser | Peringatan domain mencurigakan / halaman peniru instansi | Tahap 2 |
| Modul penjual UMKM | Peringatan bukti transfer janggal | Roadmap |
| Filter DNS/VPN lokal | Peringatan/blokir domain judol & pinjol ilegal terverifikasi | Roadmap |

### 4.3 Prinsip desain dan keselamatan

- **Jangan pernah menyatakan sesuatu "aman".** Gunakan: "tidak ditemukan tanda bahaya yang kami kenali".
- **Hanya memperingatkan**, tidak memblokir otomatis, kecuali untuk daftar yang sudah pasti jahat.
- Jangan menampilkan label "penipu" tanpa dasar; tampilkan sebagai **indikasi** dan rujuk sumber resmi.
- Pairing keluarga **wajib persetujuan eksplisit** dari lansia; isi notifikasi seminimal mungkin.
- Overlay (tahap 2): **hanya atas ketukan pengguna**, tidak memantau layar atau notifikasi terus-menerus; tampilkan kalimat "Hanya memeriksa saat Anda menekan tombol ini"; gambar tetap diproses di perangkat dan tidak disimpan.
- **Aturan teks UI:** jangan memakai kata "aman" dalam bentuk apa pun yang bisa terbaca sebagai jaminan (termasuk "dianalisis dengan aman"); pakai "diproses di ponsel Anda".
- Modul bukti transfer: CV **tidak bisa membuktikan uang masuk**. Posisikan sebagai peringatan (templat tidak cocok, teks tidak konsisten) dan tetap sarankan cek mutasi rekening.

## 5. Pendekatan "satu mesin, banyak pintu"

Bangun satu mesin penilaian risiko, lalu sediakan beberapa pintu masuk:

1. **Bagikan tangkapan layar (MVP):** membawa CV/OCR, menjangkau chat (tempat sebagian besar penipuan terjadi), cocok untuk lansia.
2. **Gelembung overlay (tahap 2):** pintu masuk ala Google Lens/Circle to Search. Pengguna mengetuk gelembung, aplikasi menangkap layar saat itu, lalu memakai mesin yang sama. Lebih praktis daripada Bagikan, tetapi butuh izin overlay dan persetujuan penangkapan layar (yang dapat diminta ulang tiap sesi), sehingga tidak dijadikan fondasi MVP. **[Belum diverifikasi]** kebijakan Google Play dan perilaku MediaProjection di Android terbaru.
3. **Ekstensi browser (opsional):** proaktif ala adblocker untuk mahasiswa di laptop; memakai mesin yang sama lewat API.
4. **DNS/VPN lokal (roadmap):** hanya melihat nama domain (lalu lintas terenkripsi), jadi tidak melibatkan CV; murni reputasi domain.

Alasan tidak menjadikan adblocker-style sebagai inti: penipuan banyak terjadi di chat dan telepon, bukan hanya situs; di level DNS tidak ada ruang untuk analisis isi; risiko salah blokir; dan izin pembacaan layar/notifikasi otomatis di Android dibatasi ketat kebijakan toko aplikasi (**[Belum diverifikasi]**, cek kebijakan terbaru).

## 6. Arsitektur teknis

```
[HP pengguna]
  ├─ Share sheet → gambar   (tahap 2: gelembung overlay → tangkap layar)
  ├─ OCR on-device (ML Kit / Tesseract)
  ├─ Ekstraksi entitas (regex): rekening, telepon, URL, nama organisasi
  ├─ Penilaian risiko: aturan + klasifikasi teks (TFLite kecil)
  ├─ Penjelasan berbasis templat (tanpa kirim gambar ke server)
  └─ Tombol "Tanya keluarga" → kirim ringkasan termasker
            │
            ▼
[Server kecil] → Firestore (data pairing) + FCM (push ke pendamping)
            │
            ▼
[HP pendamping] → notifikasi + balasan cepat

[Dashboard/landing] → hosting statis
```

**Prinsip:** skor risiko sepenuhnya di HP, sehingga hasil instan untuk lansia, biaya server minimal, dan data pribadi tidak keluar perangkat. Server hanya untuk pairing dan notifikasi keluarga, yang toleran terhadap jeda beberapa detik hingga satu menit.

**Stack yang diusulkan:** Flutter (Android dulu), ML Kit/Tesseract, TFLite, Firebase (Auth, Firestore, FCM), server ringan (Flask atau Node.js), hosting statis.

## 7. Rencana biaya: pengembangan tanpa kartu

Hampir semua komponen bisa gratis, tetapi kebijakan layanan sering berubah. **Verifikasi di halaman pendaftaran masing-masing.**

**Gratis tanpa kartu (terverifikasi atau umum diketahui):**
- Flutter, Android Studio, emulator.
- OCR on-device: ML Kit atau Tesseract (**[Belum diverifikasi]** detail lisensi/kuota).
- Pelatihan model: Google Colab atau Kaggle Notebooks (kuota GPU terbatas; mungkin perlu verifikasi nomor HP).
- Firebase paket Spark: tanpa metode pembayaran; FCM termasuk produk gratis. **[Terverifikasi]**
- Hosting statis (GitHub Pages, Cloudflare Pages, Netlify, Vercel): tanpa kartu. **[Terverifikasi]**
- Gemini API free tier: tanpa billing. **[Terverifikasi]**

**Perlu hati-hati:**
1. **Cloud Functions membutuhkan paket Blaze** (bayar sesuai pemakaian). Jangan andalkan untuk notifikasi keluarga; pakai server kecil yang memanggil FCM. **[Terverifikasi]**
2. **Backend gratis dengan jeda bangun.** Render: web service gratis tidur setelah 15 menit tanpa trafik, butuh ±1 menit untuk aktif lagi, 750 jam/bulan. Soal kartu, sumber bertentangan (ada yang menyebut tidak perlu, ada pengujian yang menyebut verifikasi kartu dengan penahanan $1) → **cek saat daftar**. Koyeb mewajibkan kartu sejak Februari 2026. **[Terverifikasi, dengan sumber bertentangan]**
3. **Gemini free tier dan privasi:** permintaan gratis dapat dipakai Google untuk memperbaiki produknya, dan batas per model hanya terlihat di konsol. Jangan kirim tangkapan layar mentah; pakai penjelasan berbasis templat atau kirim ringkasan fitur yang sudah disamarkan. **[Terverifikasi]**
4. **Hugging Face Spaces (Docker/Gradio)** disebut butuh paket berbayar sejak Juli 2026 (satu sumber). Jangan dijadikan andalan. **[Terverifikasi lemah]**
5. **Distribusi:** pendaftaran Play Console setahu saya berbayar satu kali (**[Belum diverifikasi]**). Untuk lomba, bagikan APK lewat GitHub Releases/Drive. Ekstensi Chrome bisa dimuat manual (unpacked) untuk demo.

**Di proposal:** tulis biaya pilot Rp0 dengan layanan gratis, dan hitung biaya produksi terpisah (server selalu aktif, kuota data, dsb.).

## 8. Data dan evaluasi

### 8.1 Pengumpulan data
- Sumber: materi edukasi publik tentang penipuan, contoh yang dibagikan sukarela oleh pengguna (dengan persetujuan), dan data sintetis untuk variasi.
- **Samarkan data pribadi** (nama, nomor, wajah) sebelum disimpan.
- Skema label: `penipuan`, `mencurigakan`, `normal`.
- **Wajib ada contoh "normal tapi mirip penipuan"** (hard negatives), misalnya notifikasi bank asli, promo resmi, supaya sistem tidak asal menuduh.

### 8.2 Metrik
- Precision, recall, dan terutama **false negative rate** (kasus yang lolos adalah yang paling berbahaya).
- Latensi pada HP kelas menengah.
- Uji pengguna lansia: tingkat keberhasilan tugas, waktu menyelesaikan, skor kegunaan (misalnya SUS).
- Waktu dari tombol "Tanya keluarga" sampai notifikasi diterima.

## 9. Model bisnis dan keberlanjutan

- **Pengguna akhir:** gratis.
- **Calon pembayar/mitra:** bank dan e-wallet (perlindungan nasabah), pemda dan OJK daerah (program literasi), kampus dan komunitas lansia (RT/RW, posyandu lansia).
- **Pemeliharaan:** aturan dan model perlu diperbarui saat modus baru muncul. Tentukan penanggung jawab dan sumber pembaruan (laporan pengguna, materi edukasi OJK).
- Pasar B2G/B2B lambat; mulai dari pilot kecil.

## 10. Rencana pilot

- **Mahasiswa kampus** sebagai penguji tangkapan layar umum.
- **Satu komunitas lansia** (RW, posyandu lansia, atau kelompok pengajian) bersama keluarganya untuk mode pendamping.
- Target awal: 10–20 pengguna untuk cerita yang meyakinkan (sesuaikan dengan kapasitas tim).
- Kumpulkan: umpan balik kualitatif, jumlah pesan mencurigakan yang dipindai, dan kasus salah klasifikasi.

## 11. Risiko dan mitigasi

| Risiko | Mitigasi |
|---|---|
| Rasa aman palsu (false negative) | Wording "tidak ditemukan tanda bahaya yang kami kenali"; ukur FNR; edukasi di antarmuka |
| Salah menuduh pesan asli (false positive) | Hanya memperingatkan; hard negatives di data; tombol "ini bukan penipuan" untuk umpan balik |
| Privasi data lansia | Proses di perangkat; persetujuan eksplisit; ringkasan termasker; kepatuhan UU PDP |
| Modus penipuan terus berubah | Pembaruan aturan berkala; mekanisme laporan pengguna |
| Pencemaran nama | Rujuk sumber resmi; tampilkan sebagai indikasi |
| Ketergantungan layanan gratis | On-device-first; rencana migrasi dan estimasi biaya produksi |
| Kebijakan toko aplikasi | Jangan jadikan pembacaan layar/notifikasi otomatis fondasi MVP |

## 12. Pertanyaan yang kemungkinan diajukan juri

1. Kenapa bukan CekRekening.id atau Kredibel saja?
2. Bagaimana jika sistem salah menilai pesan asli sebagai penipuan?
3. Bagaimana privasi lansia dijaga?
4. Siapa yang memperbarui aturan saat modus baru muncul?
5. Seberapa akurat sistem pada tangkapan layar nyata, bukan dataset?
6. Siapa yang membayar, dan apa yang terjadi setelah lomba selesai?

## 13. Rencana kerja (isi setelah tenggat dan tim diketahui)

- Tenggat pendaftaran/proposal: *[belum diketahui]*
- Jumlah anggota tim: *[belum diketahui]*

Urutan pengerjaan yang disarankan (durasi disesuaikan):

1. **Validasi:** kumpulkan set tangkapan layar awal, uji OCR dan aturan dasar. Jika hasil buruk, sesuaikan ide lebih awal.
2. **Kerangka end-to-end:** Bagikan → OCR → skor → hasil di layar, walau sederhana.
3. **Pendamping keluarga:** pairing, notifikasi, balasan cepat.
4. **Nilai tambah:** penjelasan "kenapa", lapor terpandu, mode suara untuk lansia.
5. **Pilot kecil, metrik, dan proposal/demo.**

Pembagian peran (jika tim lebih dari satu orang): mobile; backend dan notifikasi; data dan model; proposal, bisnis, dan pilot.

## 14. Daftar hal yang perlu diverifikasi sebelum proposal final

- [ ] Profil/usia korban dari sumber resmi (OJK).
- [ ] Ketersediaan API atau cara akses sumber pengecekan (CekRekening.id, Kredibel, daftar Satgas PASTI).
- [ ] Kebijakan Google Play terbaru soal akses layar/notifikasi, izin overlay (SYSTEM_ALERT_WINDOW), dan perilaku MediaProjection di Android terbaru.
- [ ] Tipografi final: ekspor Stitch memakai Montserrat + Plus Jakarta Sans; putuskan tetap atau ganti ke Poppins.
- [ ] Ganti teks "dengan aman" pada layar Beranda dan Mode Lansia di Stitch.
- [ ] Syarat kartu pada layanan backend yang dipilih (Render dan alternatif).
- [ ] Biaya dan metode pembayaran pendaftaran Play Console.
- [ ] Panduan resmi ADIKARA: kriteria penilaian, format proposal, tenggat.
- [ ] Pemetaan SDG/Asta Cita yang paling sesuai dengan daftar yang ditetapkan lomba.

## Lampiran A. Ide alternatif yang sudah dipertimbangkan

- **Laporan kerusakan jalan/sampah dengan CV + dashboard prioritas:** aman dikerjakan, tetapi paling mudah dianggap umum kecuali ada verifikasi before-after dan skor prioritas.
- **Aksara Bali (pembaca dan pemeriksa papan nama):** kebaruan tinggi dan ada dorongan regulasi di Bali; aplikasi transliterasi dan prototipe OCR sudah ada, celahnya di pembacaan papan nyata, pemeriksaan kebenaran penulisan, dan dashboard kepatuhan. Risiko: butuh validator bahasa dan mitra di Bali.
- **Triase kerusakan bangunan pascagempa, audit aksesibilitas fasilitas publik, aksara Sunda, pengenal diagram tulisan tangan:** alternatif yang lebih jarang digarap.

## Lampiran B. Sumber

- Data IASC/OJK (kerugian dan laporan): https://keuangan.kontan.co.id/news/hingga-14-januari-2026-kerugian-masyarakat-akibat-penipuan-scam-rp-91-triliun
- Rincian modus dan sebaran wilayah: https://finansial.bisnis.com/read/20260122/563/1946474/ojk-ungkap-wilayah-ini-sering-jadi-korban-scam-ada-303114-kasus
- Data Jawa Barat: https://jabar.jpnn.com/jabar-terkini/32845/jawa-barat-jadi-provinsi-dengan-laporan-scam-tertinggi-di-indonesia-tembus-131-ribu
- CekRekening.id: https://en.tempo.co/amp/1841665/dont-fall-for-online-scams-quick-ways-to-check-bank-accounts-for-fraud
- Catatan bahwa pengecekan rekening bukan jaminan: https://ekbis.harianjogja.com/r-1269936/cara-cek-rekening-penipu-online-sebelum-transfer-ini-panduannya
- Harga dan paket Firebase: https://firebase.google.com/pricing dan https://magora-systems.com/firebase-pricing/
- Render (free tier): https://render.com/articles/platforms-with-a-real-free-tier-for-developers-in-2026
- Uji kebutuhan kartu pada hosting Docker: https://flywp.com/blog/9769/best-free-docker-hosting-platforms
- Perbandingan hosting gratis 2026: https://snapdeploy.dev/blog/free-cloud-deployment-platforms-2026-comparison
- Perubahan kebijakan Koyeb: https://snapdeploy.dev/blog/best-heroku-alternatives-2026
- Gemini API free tier: https://benchlm.ai/free-tier/google-ai-studio

## Lampiran C. Status pengerjaan (9 Nov 2026)

**Sudah ada**
- Proposal Word di atas template ADIKARA (`Proposal_Cek_Dulu_ADIKARA2026_v2.docx`, 17 halaman): sampul, abstrak, daftar isi, Bab 1 sampai 7, daftar pustaka. Memuat fitur overlay (Bab 3, 5.9, 6, 7).
- Brief Stitch (`stitch-cek-dulu.md`): design system + 12 prompt layar; font Montserrat (judul) dan Poppins (isi).
- Desain Stitch: 4 dari 12 layar (beranda/riwayat, pemindaian, hasil risiko tinggi, hasil mode lansia). Logo header yang rusak sudah ditambal di versi untuk proposal.
- Mockup overlay (gelembung + kartu hasil) dibuat manual, masuk Gambar 7.5.

**Belum ada / perlu diisi**
- Nama tim, ketua, anggota, NIM, email (sampul proposal).
- Tenggat lomba, jumlah anggota, pembagian peran dan jadwal (bagian 13).
- Tautan prototipe (Bab 6.4).
- Layar Stitch yang belum dibuat: onboarding + persetujuan pairing, konfirmasi Tanya keluarga, notifikasi pendamping, lapor terpandu, hasil mencurigakan, hasil tanpa tanda bahaya, share sheet, gelembung overlay versi Stitch.
- Semua item verifikasi di bagian 14 (termasuk profil korban dari OJK dan pemetaan SDG/Asta Cita).
- Prototipe nyata dan hasil pilot; proposal saat ini hanya memuat rencana dan metrik, tanpa klaim akurasi.
