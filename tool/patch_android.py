#!/usr/bin/env python3
"""Menambahkan pintu masuk "Bagikan" (gambar dan teks) ke AndroidManifest.

Dijalankan setelah `flutter create`. Aman dijalankan berulang kali.
"""
import re
import sys
from pathlib import Path

path = Path(sys.argv[1] if len(sys.argv) > 1 else "android/app/src/main/AndroidManifest.xml")
xml = path.read_text(encoding="utf-8")

MARK = "<!-- cek_dulu: share targets -->"
FILTERS = f"""            {MARK}
            <intent-filter>
                <action android:name="android.intent.action.SEND"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <data android:mimeType="image/*"/>
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <data android:mimeType="text/plain"/>
            </intent-filter>
"""

if MARK in xml:
    print("Manifest sudah dipatch, tidak ada perubahan.")
    sys.exit(0)

# Paket receive_sharing_intent meminta launchMode singleTask.
xml = xml.replace('android:launchMode="singleTop"', 'android:launchMode="singleTask"')
# Nama aplikasi di launcher.
xml = re.sub(r'android:label="[^"]*"', 'android:label="Cek Dulu"', xml, count=1)

idx = xml.find("</activity>")
if idx < 0:
    sys.exit("Tag </activity> tidak ditemukan. Tambahkan intent-filter manual (lihat README).")
xml = xml[:idx] + FILTERS + "        " + xml[idx:]
path.write_text(xml, encoding="utf-8")
print("Manifest dipatch: launchMode singleTask, label, dan share target gambar/teks.")
