# FireNotes

A small SwiftUI iOS app for learning Firebase: anonymous Auth, a real-time Firestore
listener, and per-user security rules. Add notes, tap to toggle done, swipe to delete.

## Prerequisites

- Full Xcode, selected with `xcode-select -p` (not just the command line tools), plus an
  iOS Simulator runtime (Xcode → Settings → Components).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- Node.js, for the Firebase CLI (installed locally, not globally).
- A Google account that can create Firebase projects.

## Getting started

1. **Install the Firebase CLI** (local dev dependency) and log in:

   ```bash
   npm install
   npx firebase login
   ```

2. **Set the bundle ID.** Change `PRODUCT_BUNDLE_IDENTIFIER` (and `bundleIdPrefix`) in
   `project.yml` to your own, then generate the Xcode project. The `.xcodeproj` is
   generated and git-ignored; never edit it by hand.

   ```bash
   xcodegen
   ```

3. **Create the Firebase project.** If `projects:create` fails with a 403 on "add
   Firebase", add the project in the [Firebase console](https://console.firebase.google.com)
   (Add project → Select an existing Google Cloud project), then:

   ```bash
   npx firebase projects:create <project-id> --display-name <name>
   npx firebase use <project-id>
   ```

4. **Register the iOS app** and download its config into the app bundle:

   ```bash
   npx firebase apps:create ios FireNotes --bundle-id <your-bundle-id>
   npx firebase apps:sdkconfig IOS <app-id> --out FireNotes/GoogleService-Info.plist
   xcodegen
   ```

   `GoogleService-Info.plist` is git-ignored, so each clone needs its own copy.

5. **Console steps** (the CLI can't do these):
   - Firestore Database → Create database (pick a location; it can't be changed later).
   - Authentication → Get started → Sign-in method → enable **Anonymous**.

6. **Deploy the security rules:**

   ```bash
   npm run deploy:rules
   ```

7. **Build for the simulator:**

   ```bash
   xcrun simctl list devices available
   xcodebuild -scheme FireNotes -destination 'platform=iOS Simulator,name=<device>' -derivedDataPath build build
   ```

8. **Run it:**

   ```bash
   xcrun simctl boot <device-udid>
   xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/FireNotes.app
   xcrun simctl launch booted <your-bundle-id>
   ```

   You can also open the generated `FireNotes.xcodeproj` in Xcode and press Run.

## Viewing the data

Firebase console → Firestore Database → `users` → `<uid>` → `notes`. The uid is shown at
the bottom of the app. Edits made in the console appear live in the app.

## Project layout

- `FireNotes/FireNotesApp.swift`: calls `FirebaseApp.configure()`.
- `FireNotes/Note.swift`: `Codable` model with `@DocumentID` and `@ServerTimestamp`.
- `FireNotes/NotesStore.swift`: `@Observable` store with auth, listener and CRUD.
- `FireNotes/ContentView.swift`: the UI.
- `firestore.rules`: restricts each user to their own notes.
- `project.yml`: XcodeGen spec.

Simulator only; a device build needs your own signing team.
