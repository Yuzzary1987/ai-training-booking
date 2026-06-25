# Archamella Music Player

Winamp-style MP3 player untuk Android.

Lokasi projek:

```txt
Yuzzary1987/ai-training-booking
└── archamella-music-player
```

Branch kerja:

```txt
archamella-music-player-v2
```

## Preview UI

```txt
┌────────────────────────────────────┐
│  🎚 ARCHAMELLA PLAYER              │
│  Winamp-style MP3 library Android  │
└────────────────────────────────────┘

[ Search song, artist, album... ]

♪ Gerak Hati.mp3          ▶
♪ Blue Neon.mp3           ▶
♪ Daya.mp3                ▶
♪ WhatsApp Audio.mp3      ▶

┌────────────────────────────────────┐
│ No song selected                   │
│ Tap any song to play               │
│      ⏮      ▶      ⏭              │
└────────────────────────────────────┘
```

## Fungsi versi ini

- Scan lagu daripada telefon Android.
- Papar music library.
- Search lagu, artist dan album.
- Play / pause.
- Next / previous.
- Album artwork jika ada.
- UI gelap neon ala Winamp moden.
- App boleh install dan uninstall seperti app Android biasa selepas dibina sebagai APK.

## Cara buka dalam komputer

Pastikan Flutter sudah dipasang.

```bash
git clone https://github.com/Yuzzary1987/ai-training-booking.git
cd ai-training-booking/archamella-music-player
git checkout archamella-music-player-v2
flutter create .
flutter pub get
flutter run
```

## Cara buat APK

```bash
flutter build apk --release
```

Fail APK akan keluar di:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

Copy fail APK itu ke handphone Android dan tekan install.

## Cara uninstall dari handphone

```txt
Settings > Apps > Archamella Player > Uninstall
```

## Permission diperlukan

App akan minta akses audio/storage untuk scan fail MP3 dalam telefon.

## Fasa seterusnya

- Equalizer 10-band.
- Visualizer spectrum.
- Playlist.
- Favorites.
- Folder browser.
- Sleep timer.
- Lock screen control.
- Notification player.
- Widget Android.
