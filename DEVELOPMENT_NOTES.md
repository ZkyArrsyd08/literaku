# Literaku Development Notes

## Struktur dan sistem

- `data/alphabet_data.gd`: data A–Z, kata contoh, dan emoji.
- `scripts/managers`: navigasi global, progres JSON lokal, dan audio fallback aman.
- `scenes/game/game_screen.tscn`: layar reusable untuk pemilihan, detail, permainan, koleksi, dan tracing.
- `scripts/writing`: data stroke dan canvas tracing untuk huruf kapital serta kecil.

## Menjalankan

Buka `project.godot` di Godot 4 lalu tekan `F6` atau `F5`.

## Mengganti asset

Logo ada di `assets/images/literaku_logo.png`, Lumi di `assets/characters/lumi_mascot_transparent.png`, dan background di `assets/backgrounds/`. Pertahankan nama file agar scene langsung memakai penggantinya.

## Audio

Tambahkan file pengucapan di `audio/voice/`, lalu sambungkan di `AudioManager`. Saat file belum ada, permainan tetap aman menggunakan fallback tanpa suara.

## Kosakata dan tracing

Ubah kata dan emoji dalam `data/alphabet_data.gd`. Jalur tracing memakai koordinat 0–1 di `scripts/writing/tracing_data.gd`, sehingga otomatis berskala pada canvas.

## Pengujian manual

Uji tiap tombol menu, semua kartu huruf, detail, pencocokan, berburu huruf, tracing, dan Buku Koleksi. Progres tersimpan pada `user://literaku_progress.json`.
