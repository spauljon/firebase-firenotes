# FireNotes

A throwaway SwiftUI iOS app for experimenting with Firebase. The goal is learning
Firebase (Auth, Firestore, security rules, emulators), not shipping a product.
Keep the app small and simple.

## Current state
- Source files in `FireNotes/` are written but have never been compiled. Expect
  to fix small errors.
- `project.yml` is the XcodeGen spec. **The .xcodeproj is generated and
  git-ignored. Never hand-edit it; change project.yml and re-run `xcodegen`.**
- Bundle ID `com.CHANGEME.firenotes` is a placeholder. Ask me for the real one
  before creating the Firebase app.
- Firebase SDK is pinned `from: "12.0.0"`. Check the latest firebase-ios-sdk
  release and bump if needed.

## What the app does
- Anonymous Firebase Auth on launch (reuses the existing session).
- Real-time Firestore listener on `users/{uid}/notes`, ordered by `createdAt`
  desc.
- Add, toggle done, and swipe-to-delete notes.
- `firestore.rules` restricts each user to their own notes.

## Files
- `FireNotesApp.swift` calls `FirebaseApp.configure()`.
- `Note.swift` is a Codable model with `@DocumentID` and `@ServerTimestamp`.
- `NotesStore.swift` is the `@Observable` store with the auth, listener, and
  CRUD logic.
- `ContentView.swift` is the UI.

## Getting it running (in order)
1. Check the prerequisites: full Xcode selected (`xcode-select -p`) and
   `xcodegen` (global, via brew). Tell me what's missing rather than
   installing silently. The Firebase CLI is a **local dev dependency**: run
   `npm i -D firebase-tools` if `node_modules/` is missing. Always invoke it
   as `npx firebase ...`, never a global `firebase`.
2. Fill in the bundle ID in project.yml, then run `xcodegen`.
3. Run `npx firebase projects:list` to confirm I'm logged in. If not, stop and ask
   me to run `npx firebase login`.
4. Create or select the Firebase project (ask me for the project ID), then
   run `npx firebase use <id>`.
5. Register the iOS app (`npx firebase apps:create ios ...`) and write
   `npx firebase apps:sdkconfig ios <appId>` output to
   `FireNotes/GoogleService-Info.plist`. Make sure it lands in the app bundle
   resources (regenerate the project afterward).
6. Create the Firestore database if it doesn't exist, then run
   `npm run deploy:rules`.
7. **Stop and ask me** to enable Anonymous sign-in in the console
   (Authentication → Sign-in method). The CLI can't toggle auth providers.
8. Build for the simulator with `xcodebuild -scheme FireNotes
   -destination 'platform=iOS Simulator,name=<some iPhone>' build`. List
   simulators with `xcrun simctl list devices available`. Fix errors until it
   builds clean.
9. Boot the simulator, then install and launch the app with
   `xcrun simctl install/launch`. Bundle ID is from step 2.

## Conventions
- Simulator only unless I ask for a device build (that needs my signing team).
- Any step that needs a browser or the Firebase console: stop and tell me
  exactly what to click.
- Don't create or delete Firebase projects or databases without confirming.

## Later experiments (don't start unprompted)
- Point the app at local emulators (`npm run emulators`) behind a DEBUG
  flag.
- Sign in with Apple instead of anonymous auth.
- A Cloud Function triggered on new notes.
