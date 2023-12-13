import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Workaround to make setData(from:) ASYNC
extension DocumentReference {
  func setData<T: Encodable>(from value: T) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      /// Method only throws if there’s an encoding error, which indicates a problem with our model.
      /// We handled this with a force try, while all other errors are passed to the completion handler.
      try! setData(from: value) { error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        continuation.resume()
      }
    }
  }
}


/// Same as Swiftful Thinking, get all docs at once.
extension Query {
  func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
    let snapshot = try await getDocuments()
    return snapshot.documents.compactMap { document in
      try! document.data(as: type)
    }
  }
}
