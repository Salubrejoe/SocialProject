import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



protocol CommentsRepositoryProtocol {
  var user: User { get }
  var post: Post { get }
  func fetchComments() async throws -> [Comment]
  func create(_ comment: Comment) async throws 
  func delete(_ comment: Comment) async throws
}

extension CommentsRepositoryProtocol {
  /// Users can delete comments if they’re the author of the comment
  /// or the post the comment is on.
  /// We’ll also use the post property to know which comments to fetch.
  func canDelete(_ comment: Comment) -> Bool {
    [comment.author.id, post.author.id].contains(user.id)
  }
}


struct CommentsRepository: CommentsRepositoryProtocol {
  let user: User
  let post: Post
  
  private var commentsReference: CollectionReference {
    let postsReference = Firestore.firestore().collection("posts_v3")
    let document = postsReference.document(post.id.uuidString)
    return document.collection("comments")
  }
  
  func fetchComments() async throws -> [Comment] {
    return try await commentsReference
      .order(by: "timestamp", descending: true)
      .getDocuments(as: Comment.self)
  }
  
  func create(_ comment: Comment) async throws {
    let documentReference = commentsReference.document(id(for: comment))
    try await documentReference.setData(from: comment)
  }
  
  func delete(_ comment: Comment) async throws {
    precondition(canDelete(comment))
    let document = commentsReference.document(id(for: comment))
    try await document.delete()
  }
  
  private func id(for comment: Comment) -> String {
    comment.id.uuidString
  }
}
