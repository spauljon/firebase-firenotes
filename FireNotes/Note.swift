import Foundation
import FirebaseFirestore

struct Note: Identifiable, Codable {
    @DocumentID var id: String?          // filled in from the Firestore document ID
    var text: String
    var done: Bool = false
    @ServerTimestamp var createdAt: Date? // set by the server on write
}
