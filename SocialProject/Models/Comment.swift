import Foundation

struct Comment: Identifiable, Equatable, Codable {
  var id = UUID()
  var content: String
  var author: User
  var timestamp = Date()
}
