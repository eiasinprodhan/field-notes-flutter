# Field Notes — Flutter App

Offline-first mobile app for field workers (ATI Limited take-home). Pairs with the
Spring Boot backend in `../field-notes-backend`.

## Stack
- Flutter 3.x (Dart 3)
- **BLoC** for state management
- **sqflite** for offline-first local storage (schema mirrors the backend 1:1)
- **Dio** for the REST client
- **permission_handler / geolocator / image_picker** for location + camera/gallery
- **shared_preferences** for local-only settings
- **connectivity_plus** to trigger sync when the network returns

## Architecture
```
lib/
  main.dart                  # wires the dependency graph (repos, blocs, db, api)
  app.dart                   # MultiBlocProvider + MaterialApp + auth gate
  core/
    constants.dart           # API base URL, SharedPreferences keys
    network/                 # Dio client (+ JWT interceptor), token storage
    storage/                 # settings storage (default note status, last sync)
  models/                    # Customer, Site, FieldNote, Auth, NoteStatus, Sync DTOs
  data/
    local/app_database.dart  # SQLite schema + offline CRUD + sync metadata
    remote/api_client.dart   # REST calls (auth, CRUD, photos, sync)
    repositories/            # AuthRepository, FieldRepository (offline-first core)
  bloc/                      # auth, customer, site, note, sync, settings, connectivity
  presentation/
    screens/                 # auth, home, customers, sites, notes, settings
    utils/permissions.dart   # location + camera/gallery permission helpers
```

### Offline-first + sync (the important part)
1. **All reads** come from the local SQLite DB, so the UI works with no network.
2. **All writes** are applied locally first and flagged `sync_pending = 1`
   (plus a soft-delete flag, and the stable client `uuid` + `updatedAt` timestamp).
3. `FieldRepository.sync()` does the reconciliation:
   - **Push** every dirty row as a batch (`POST /api/sync/push`).
   - **Pull** everything changed since the last sync (`GET /api/sync/pull?since=`,
     or a full set on first sync / after reinstall).
   - **Merge** with **last-write-wins** on `updatedAt` (mirrors the server).
4. `SyncBloc` runs a sync on login and automatically whenever the device goes
   back online (`ConnectivityBloc`).

### Features implemented
- Register / log in (JWT, persisted so the session survives restart)
- CRUD for customers, sites, and field notes (works offline)
- Search notes by title/description/**site/customer name** + filter by status/site
  (resolved locally, so it works offline too)
- Location capture (GPS) and photo capture (camera/gallery) with proper permission
  handling
- Settings → **Default Note Status** stored locally, auto-filled on new notes,
  persists after restart, and is intentionally NOT synced
- Data isolation is enforced server-side (every query is scoped to the user)

## Run it
```bash
# 1) Point the app at your backend (see lib/core/constants.dart -> ApiConstants.baseUrl).
#    Android emulator: http://10.0.2.2:8080
#    Physical device : your machine's LAN IP, e.g. http://192.168.1.10:8080

# 2) Get dependencies
flutter pub get

# 3) Run
flutter run
```
> Note: this project was authored in an environment without a Flutter SDK, so it
> has not been compiled here. Run `flutter pub get && flutter analyze` on your
> machine; with a current Flutter 3.x it should build cleanly. Adjust dependency
> versions in `pubspec.yaml` if `pub get` reports a newer major.

## Android / iOS permissions
- `android/app/src/main/AndroidManifest.xml` needs INTERNET, ACCESS_FINE_LOCATION,
  CAMERA, and READ/WRITE external storage (scoped) entries.
- `ios/Runner/Info.plist` needs NSLocationWhenInUseUsageDescription,
  NSCameraUsageDescription, and NSPhotoLibraryUsageDescription.
