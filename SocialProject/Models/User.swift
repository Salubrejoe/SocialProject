import Foundation
import FirebaseAuth

struct User: Identifiable, Equatable, Codable {
  var id: String
  var name: String
  var imageURL: URL?
}

extension User {
  init(from firebaseUser: FirebaseAuth.User) {
    self.id = firebaseUser.uid
    self.name = firebaseUser.displayName ?? ""
    self.imageURL = firebaseUser.photoURL
  }
}

extension User {
  static let testUser = User(id: "", name: "David Luiz")
}
