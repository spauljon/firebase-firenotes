import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct FireNotesApp: App {
    init() {
        // Reads GoogleService-Info.plist from the app bundle
        FirebaseApp.configure()

        #if DEBUG
        // Opt in with USE_EMULATORS=1 (Xcode scheme env var, or
        // SIMCTL_CHILD_USE_EMULATORS=1 with simctl launch). Simulator only:
        // "localhost" is the host Mac there. Ports match firebase.json.
        if ProcessInfo.processInfo.environment["USE_EMULATORS"] == "1" {
            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
            // Drop any persisted session from the real project so the
            // emulator issues its own anonymous user.
            try? Auth.auth().signOut()
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
        }
        #endif
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
