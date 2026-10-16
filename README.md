# BLE Proximity Tracker

Aplikasi Flutter untuk memindai perangkat Bluetooth Low Energy di sekitar secara real-time, melacak kedekatan satu perangkat lewat radar, dan menyimpan riwayat perangkat ke database lokal.

| Tab / layar | Isi |
|---|---|
| **Scan** | Start/Stop scan, ringkasan (jumlah perangkat aktif, sinyal terkuat), daftar perangkat (nama, MAC/UUID, estimasi jarak, RSSI mentah, meter sinyal) urut sinyal terkuat, pencarian nama/MAC, filter cepat RSSI, filter detail di bottom sheet |
| **Radar** | Radar per zona sesuai tabel brief, estimasi jarak beserta rentang zonanya, skala zona, RSSI mentah vs smoothed, stabilitas sinyal (±dB), grafik 60 pembacaan terakhir, status *Signal lost* |
| **History** | Perangkat yang pernah terdeteksi dikelompokkan per hari, waktu terakhir & pertama terlihat, RSSI terakhir & terbaik, pencarian, hapus riwayat |
| **Settings** | Tema Dark / Light / System (default), tabel zona sinyal, penjelasan model jarak |

## Setup

Prasyarat: Flutter ≥ 3.32 (Dart ≥ 3.8), Android SDK, **HP Android fisik** (emulator tidak punya BLE).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # kode drift
flutter test
flutter run
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

Setelah mengubah tabel/DAO drift: `dart run build_runner build --delete-conflicting-outputs`.

Setelah mengganti PNG di `assets/icon/`: `dart run flutter_launcher_icons`.

### Build release dan signing

- APK release ditandatangani dengan keystore release jika `android/key.properties` ada. File ini dan keystore-nya tidak masuk repo (keduanya diabaikan `android/.gitignore`). Isinya:

  ```properties
  storePassword=<password>
  keyPassword=<password>
  keyAlias=upload
  storeFile=<path absolut ke file .jks>
  ```

- Tanpa `key.properties` (misalnya setelah clone), build release otomatis memakai debug key. APK-nya tetap bisa diinstal untuk diuji.
- Library native dikompresi di dalam APK (`useLegacyPackaging = true`), sehingga APK universal turun dari 57,7 MB menjadi 26,7 MB. Saat instal, Android hanya mengekstrak library untuk arsitektur HP tersebut.
- `flutter build apk --release --split-per-abi` menghasilkan APK per arsitektur (arm64 sekitar 10 MB). APK universal tetap disediakan karena cukup satu file untuk semua HP.

## Arsitektur

Clean Architecture per fitur, state management BLoC (pola MVI: event → bloc → state).

```
lib/
├── core/
│   ├── bluetooth/              dipakai bersama fitur scanner & radar
│   │   ├── domain/             entities, BluetoothRepository (interface), use cases
│   │   └── data/               BleDataSource (universal_ble), BluetoothRepositoryImpl
│   ├── signal/                 zona RSSI, estimasi jarak, smoothing, throttle guard
│   ├── error/                  Failure (sealed), Result<T> (Ok / Err)
│   ├── di/injection.dart       registrasi get_it (composition root)
│   ├── router/                 go_router + bottom navigation shell
│   ├── theme/                  warna neumorphism, font digital, tema dark & light
│   ├── widgets/                komponen UI bersama (NeuBox, NeuButton, DigitalReadout, …)
│   └── utils/
└── features/
    ├── scanner/   domain/ (DeviceFilter, FilterNearbyDevices)  presentation/ (ScannerBloc, page, widgets)
    ├── radar/     domain/ (ProximitySnapshot, TrackDeviceProximity)  presentation/ (RadarBloc, page, widgets)
    ├── history/   domain/  data/ (drift: AppDatabase, DeviceHistoryDao)  presentation/ (HistoryCubit)
    └── settings/  domain/  data/ (shared_preferences)  presentation/ (ThemeCubit, page)
```

Aturan dependensi:

- `domain` hanya Dart murni + `equatable`. Tidak mengenal Flutter, drift, atau universal_ble.
- `data` mengimplementasikan interface repository milik `domain`.
- `presentation` hanya memanggil use case, tidak pernah repository atau data source.
- Antar fitur hanya lewat `domain`. Satu pengecualian yang disengaja: `ScannerBloc` disediakan di level aplikasi, sehingga layar radar membacanya untuk memastikan scan aktif dan mengambil pembacaan terakhir.

Alur data scan: `universal_ble` → `BleDataSource` → `BluetoothRepository` → use case `WatchAdvertisements` → `ScannerBloc` (buffer, flush tiap 500 ms) → UI. Setiap flush juga memanggil `RecordSightings` ke drift; `HistoryCubit` menerima perubahan lewat query reaktif. `RadarBloc` memakai `TrackDeviceProximity` yang subscribe langsung ke paket perangkat target.

## Library

| Library | Alasan |
|---|---|
| `flutter_bloc`, `bloc_concurrency` | BLoC untuk scanner & radar, Cubit untuk history & tema. `sequential()` membuat perintah start/stop tidak saling tumpang tindih |
| `get_it` | Service locator untuk DI; registrasi manual di satu file, tanpa code generation |
| `equatable` | Perbandingan state/entity tanpa boilerplate |
| `universal_ble` | Lisensi BSD-3 tanpa batasan komersial, aktif dirawat, stream status adapter, scan mode `lowLatency` |
| `permission_handler` | Membedakan izin ditolak sekali vs permanen, membuka App Settings |
| `drift` | Padanan Room: tabel ber-tipe, DAO, query reaktif, test dengan in-memory DB |
| `shared_preferences` | Menyimpan pilihan tema |
| `go_router` | Bottom navigation (`StatefulShellRoute`) dan route detail `/radar/:id` |
| `bloc_test`, `mocktail` | Test bloc dan mock repository |
| `flutter_launcher_icons` | Membuat resource ikon Android (adaptive, legacy, monochrome) dari PNG di `assets/icon/` |

Yang sengaja tidak dipakai: **dartz** (rilis terakhir 2021; `sealed class Result<T>` Dart 3 sudah cukup) dan **freezed** (state sedikit, `equatable` + `copyWith` manual lebih sederhana dan mengurangi code generation).

## Desain UI

Gaya **neumorphism** dengan nuansa kalkulator digital.

- **Satu warna dasar untuk semua permukaan**, kecuali layar LCD (lihat di bawah). Kedalaman hanya berasal dari dua bayangan berpasangan: terang di kiri atas, gelap di kanan bawah. Tidak ada border, blur, atau gradien latar.
- **Timbul vs cekung punya arti.**
  - Kartu dan tombol timbul.
  - Layar LCD, kolom pencarian, dan meter sinyal cekung.
  - Pilihan yang aktif (filter, tab bottom navigation, tema) ikut tertekan ke dalam.
  - Tombol *Stop scan* tetap tertekan selama scan berjalan, seperti tombol kalkulator yang ditahan.
- **Satu widget dasar.** `NeuBox` (`lib/core/widgets/neu.dart`) menggambar kedua mode, timbul dan cekung, lewat satu `CustomPainter`, termasuk *inner shadow* yang tidak didukung `BoxShadow`. Saat ditekan, bayangannya beralih halus dari timbul ke cekung. Tanpa efek ripple.
- **Font.**
  - [Share Tech Mono](https://fonts.google.com/specimen/Share+Tech+Mono) untuk teks: monospace bergaya LCD yang tetap terbaca, dan MAC address jadi rata kolom.
  - [DSEG7 Classic](https://github.com/keshikan/DSEG) untuk angka: font 7-segmen seperti layar kalkulator.
  - `DigitalReadout` menggambar segmen "88" yang mati secara samar di belakang angka, seperti LCD asli.
  - DSEG tidak bisa menampilkan huruf dengan baik, jadi hanya dipakai untuk angka.
  - Kedua font berlisensi SIL OFL (`assets/fonts/OFL-*.txt`).
- **Warna.**
  - Gelap `#2A2E35` dan terang `#E0E5EC`. Default-nya mengikuti tema sistem HP, dan bisa diganti di Settings (Dark / Light / System, tersimpan).
  - Warna zona sinyal hijau → merah menjadi satu-satunya warna jenuh di UI. Untuk teks, warna zona digelapkan (tema terang) atau dicerahkan (tema gelap).
  - Semua warna teks, termasuk teks sekunder, aksen, error, dan label zona, memiliki kontras ≥ 4,5:1 terhadap warna dasar di kedua tema. Kontras rendah adalah kelemahan umum neumorphism.
- **Landscape.**
  - Bottom navigation berubah menjadi rail vertikal di kiri, supaya konten mendapat tinggi layar penuh.
  - Di layar Radar, piringan radar mengisi kolom kiri setinggi layar, sedangkan jarak dan metrik koneksi ada di kolom kanan.
- **Aksesibilitas.** Setiap tombol neumorphism (`NeuButton`, `NeuIconButton`, tab, filter, pilihan tema) adalah node semantik tersendiri yang punya label. Dengan begitu TalkBack tidak membaca seluruh kartu sebagai satu tombol, dan tombol ikon disebut dengan namanya.
- **Layar LCD.** Semua angka tampil di jendela LCD cekung (`LcdPanel` + `DigitalReadout`), seperti layar kalkulator retro. Jendela ini dipakai di statistik scan, RSSI di kartu perangkat dan riwayat, jarak di radar, dan metrik koneksi.
  - Tema terang: layar hijau keabuan `#C5D0B0`, digit `#1E2A1A` (9,3:1), label `#4A5A40` (4,6:1).
  - Tema gelap: layar hampir hitam `#141B16`, digit hijau `#8FD58A` (10,1:1) dengan cahaya samar seperti layar ber-*backlight*, label `#6E9A68` (5,4:1).
  - Panel LCD yang bertumpuk diberi lebar minimum, sehingga kolom angka tetap rata berapa pun jumlah digitnya.
- **Radar.**
  - Piringan timbul dengan cekungan di dalamnya, cincin jarak terukir, titik pusat seperti kenop, dan target seperti LED berwarna zona.
  - Sapuan radar dan denyut indikator *Scanning* adalah satu-satunya animasi berulang. Keduanya hanya berjalan selama layarnya tampil.
- Bilah navigasi sistem Android diwarnai sama dengan warna dasar.
- **Splash screen native** (tanpa paket tambahan), sewarna dengan tema supaya tidak ada kedipan warna saat aplikasi terbuka.
  - Latar `#E0E5EC` atau `#2A2E35` mengikuti mode gelap sistem, dengan knob di tengah.
  - Knob splash (`drawable-nodpi/splash_icon.png`) tidak memakai bayangan, jadi cocok di latar terang maupun gelap. Ukurannya 62% kanvas, masih di dalam mask lingkaran 2/3 milik sistem.
  - Android 12+ memakai Splash Screen API (`values-v31`, `values-night-v31`).
  - Android 11 ke bawah memakai `drawable/launch_background.xml` (knob 240 dp, setara Android 12).
  - Jendela di belakang Flutter (`NormalTheme`) juga memakai warna yang sama, jadi peralihan ke frame pertama mulus.
  - Tidak ada splash tambahan di Flutter, karena splash dengan jeda hanya memperlambat pengguna.
- **Ikon aplikasi** (`assets/icon/`) dibuat ke resource Android oleh `flutter_launcher_icons`.
  - Adaptive icon: pelat `#E0E5EC` dengan knob yang timbul berkat bayangan neumorphism, seperti tombol di dalam aplikasi.
  - Knob memenuhi 54% kanvas (58 dp), di dalam zona aman 66 dp, jadi tidak terpotong oleh mask launcher apa pun (lingkaran, squircle, dll).
  - Layer monochrome (cincin dan simbol Bluetooth) untuk *themed icons* Android 13+.
  - Ikon legacy untuk Android 7.x: pelat membulat dengan knob yang sama.
  - Inset bawaan 16% dari `flutter_launcher_icons` dimatikan (`adaptive_icon_foreground_inset: 0`), karena ukuran knob sudah diatur di PNG sumbernya.

## Keputusan teknis

- **Kalibrasi jarak.** `d = 10^((A − RSSI) / (10·n))` dengan `A = −32 dBm`, `n = 3.8`. Nilai ini dipilih agar cocok dengan tabel brief: −30 → 0,9 m, −50 → 3 m, −70 → 10 m, −80 → 18 m, −90 → 34 m.
- **Smoothing + hysteresis.** RSSI di-smooth dengan EMA (α = 0,3). Zona baru berubah setelah sinyal melewati batas lebih dari 3 dB, sehingga indikator tidak berkedip di perbatasan. Angka jarak tetap dihitung langsung dari RSSI yang di-smooth, jadi di dekat batas zona angkanya bisa sedikit di luar rentang zona (misalnya 3,4 m saat zona masih *Strong*, 1–3 m). Karena itu rentang zona ditampilkan sebagai keterangan zona, bukan sebagai judul angka jarak.
- **Batching.** Paket advertising datang puluhan kali per detik. Daftar di-update dan history ditulis setiap 500 ms dalam satu transaksi.
- **Perangkat aktif.** Perangkat yang tidak advertise selama 15 detik keluar dari daftar scan (tetap ada di History). Di radar, target dianggap hilang setelah 5 detik tanpa paket.
- **Throttling Android.** Android mengabaikan scan setelah 5 kali start dalam 30 detik tanpa memberi error. Use case `StartScan` menolak start ke-6 dan memberi tahu berapa detik harus menunggu.
- **Error handling.**
  - Bluetooth mati saat scan → scan berhenti, banner muncul, scan otomatis lanjut saat Bluetooth menyala lagi.
  - Izin ditolak → tombol *Allow*; ditolak permanen → tombol ke App Settings. Status "permanen" dideteksi lewat `shouldShowRequestRationale`, karena izin diminta lewat `universal_ble` sehingga `permission_handler` tidak bisa melaporkannya sendiri. Saat app kembali ke foreground, status izin dicek ulang tanpa memunculkan dialog, jadi banner hilang begitu izin diberikan di Settings.
  - Target hilang di radar → status *Signal lost*, pulih otomatis saat sinyal kembali.
  - Gagal menulis history tidak menghentikan scan.
- **Lifecycle.** Scan hanya berjalan di foreground: berhenti saat app ke background, lanjut saat kembali, kecuali user yang menghentikannya. Rotasi tidak me-restart scan karena `ScannerBloc` hidup di atas router dan Activity memakai `configChanges`. Struktur widget tree sama di kedua orientasi, sehingga teks pencarian dan posisi scroll tetap bertahan saat layar diputar.

## Asumsi

- Batas tabel brief saling bertumpuk (mis. −30 muncul di dua baris); nilai batas dimasukkan ke zona yang lebih kuat.
- Aplikasi hanya melakukan scan (central, tanpa koneksi GATT). "Terkoneksi" pada layar riwayat diartikan "pernah terdeteksi".
- Proyek hanya menargetkan Android (APK).
- RSSI 0/127 dari Android (tidak tersedia) dianggap −127 dBm.

## Known issues

- **MAC acak.** Banyak perangkat (HP, earbuds) mengganti MAC secara berkala, sehingga satu perangkat fisik bisa muncul beberapa kali di History.
- **Akurasi jarak.** Tembok, tubuh, orientasi HP, dan daya pancar tiap perangkat menggeser RSSI. Angka meter bersifat perkiraan; zona lebih bisa diandalkan.
- **Arah tidak diketahui.** Satu antena hanya memberi jarak, jadi posisi titik di radar menunjukkan jarak, bukan arah.
- **`neverForLocation`.** Sebagian beacon disaring Android 12+ karena flag ini. Jika beacon diperlukan, hapus flag dan minta izin lokasi.
- **Test DAO** memakai SQLite native; di Linux mungkin perlu `libsqlite3-dev`.
- **Warna splash mengikuti tema sistem, bukan pilihan di Settings.** Splash tampil sebelum Flutter berjalan, jadi belum bisa membaca preferensi tema yang tersimpan. Contohnya, kalau HP memakai mode terang tapi aplikasi diatur ke Dark, splash tetap terang lalu berganti ke gelap.

## Testing

```bash
flutter test
```

| File | Cakupan |
|---|---|
| `test/core/signal_test.dart` | Pemetaan zona, kalibrasi jarak, EMA, hysteresis, throttle guard |
| `test/core/start_scan_test.dart` | Urutan prasyarat scan dan pemetaan setiap `Failure` |
| `test/features/scanner/scanner_bloc_test.dart` | Urutan sinyal, filter, sinyal terkuat dihitung dari semua perangkat (tidak terpengaruh filter), merge nama, pruning, izin ditolak (tetap setelah resume, pulih setelah diizinkan di Settings), Bluetooth off→on, background→foreground, throttling |
| `test/features/radar/radar_test.dart` | Smoothing, zona, deteksi lost & pemulihan, filter perangkat target, `RadarBloc` |
| `test/features/history/history_test.dart` | Upsert DAO (nama, RSSI terbaik, first seen), urutan, `HistoryCubit` |
| `test/features/settings/theme_cubit_test.dart` | Default System, load & simpan preferensi |
| `test/widget_test.dart` | Tampilan `DeviceCard`, semantik aksesibilitas `NeuButton` dan `NeuIconButton` |

## Penggunaan AI

Proyek ini dikerjakan dengan bantuan AI generatif, yaitu Claude (Anthropic) melalui Claude Code.

AI dipakai untuk:

- Menulis dan merapikan kode: fitur, arsitektur, test, dan konfigurasi Android (signing release, splash screen, ikon aplikasi).
- Menerapkan desain UI: tema neumorphism, layar LCD dengan font 7-segmen, ikon aplikasi, dan layout landscape.
- Menulis dokumentasi README dan pesan commit.
- Menguji aplikasi di HP fisik lewat `adb`, termasuk menemukan dan memperbaiki bug pada penanganan izin, tampilan landscape, perhitungan sinyal terkuat, dan aksesibilitas.

Peran saya:

- Menentukan arah desain dan fitur, antara lain gaya neumorphism, font digital, layar LCD hijau, tema default yang mengikuti sistem, dan rail navigasi di landscape.
- Meninjau setiap usulan perubahan dan memutuskan mana yang dipakai.
- Menyediakan HP fisik (Samsung Galaxy A52, Android 14) untuk pengujian.
- Menyetujui pembuatan repositori, keystore release, dan rilis APK.
