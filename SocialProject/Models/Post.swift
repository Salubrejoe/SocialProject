import Foundation

struct Post: Identifiable, Equatable {
  var title      : String
  var content    : String
  var author     : User
  var imageURL   : URL?
  var id         = UUID()
  var timestamp  = Date()
  var isFavorite = false
  
  func contains(_ string: String) -> Bool {
    let properties = [title, content, author.name].map { $0.lowercased() }
    let query = string.lowercased()
    
    let matches = properties.filter { $0.contains(query) }
    return !matches.isEmpty
  }
}

extension Post: Codable {
  enum CodingKeys: CodingKey {
    case id, title, content, author, timestamp, imageURL
  }
}
