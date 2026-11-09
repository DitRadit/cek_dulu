#!/usr/bin/env bash
# Menyiapkan scaffolding Android, lalu memasang pintu masuk "Bagikan".
# Jalankan sekali dari folder project:  bash setup.sh
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter belum terpasang. Lihat https://docs.flutter.dev/get-started/install" >&2
  exit 1
fi

# --platforms=android saja; lib/, test/, assets/ dan pubspec.yaml tidak ditimpa.
flutter create . --org id.cekdulu --project-name cek_dulu --platforms=android
flutter pub get
python3 tool/patch_android.py
echo
echo "Selesai. Jalankan: flutter run   (atau: flutter test)"
