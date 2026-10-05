import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
final class NotesStore {
    var notes: [Note] = []
    var uid: String?
    var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Sign in anonymously (or reuse the existing session), then start listening.
    func start() async {
        do {
            let user: User
            if let current = Auth.auth().currentUser {
                user = current
            } else {
                user = try await Auth.auth().signInAnonymously().user
            }
            uid = user.uid
            listen(uid: user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Data layout: users/{uid}/notes/{noteId}
    private func notesRef(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("notes")
    }

    private func listen(uid: String) {
        listener?.remove()
        listener = notesRef(uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                // Firestore delivers callbacks on the main queue by default
                MainActor.assumeIsolated {
                    guard let self else { return }
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.notes = snapshot?.documents.compactMap { try? $0.data(as: Note.self) } ?? []
                }
            }
    }

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let uid, !trimmed.isEmpty else { return }
        do {
            _ = try notesRef(uid).addDocument(from: Note(text: trimmed))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggle(_ note: Note) {
        guard let uid, let id = note.id else { return }
        notesRef(uid).document(id).updateData(["done": !note.done])
    }

    func delete(_ note: Note) {
        guard let uid, let id = note.id else { return }
        notesRef(uid).document(id).delete()
    }
}
