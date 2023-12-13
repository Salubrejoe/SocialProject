import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// To instanciate a Posts View Model, the app needs a Posts Repo, which in turn only needs a User.
///
/// The Repo does:
/// 1. Create and Delete Posts
/// 2. Fetch Posts (all, by user)
/// 3. Manage favorites

struct PostsRepository {
  let user: User
  
  let postsReference     = Firestore.firestore().collection("posts_v3")
  let favoritesReference = Firestore.firestore().collection("favorites_v1")
}

// MARK: - Create and Delete
extension PostsRepository {
  func create(_ post: Post) async throws {
    var post = post
    
    /// Since this file URL won’t work on other devices,
    /// we’ll need to upload the image to Firebase Storage
    /// and update the imageURL property to point to the uploaded image.
    if let imageURL = post.imageURL {
      post.imageURL = try await StorageFile
        .with(namespace: "posts", identifier: post.id.uuidString)
        .putFile(from: imageURL)
        .getDownloadURL()
      
      /// Delete the temporary file after the upload is successful
      do {
        try FileManager.default.removeItem(at: imageURL)
      } catch {
        print("Error deleting temporary file: \(error.localizedDescription)")
      }
    }
    
    
    let documentReference = postsReference.document(post.id.uuidString)
    try await documentReference.setData(from: post)
  }
  
  func delete(_ post: Post) async throws {
    precondition(canDelete(post))
    /// After deleting the post,
    let document = postsReference.document(post.id.uuidString)
    try await document.delete()
    /// this uses an optional map to initialize the StorageFile object with the post’s image URL.
    let image = post.imageURL.map(StorageFile.atURL(_:))
    /// Then, it deletes the image from Firebase.
    try await image?.delete()
  }
  
  func canDelete(_ post: Post) -> Bool {
    post.author.id == user.id
  }
}


// MARK: - Fetch Posts
extension PostsRepository {
  
  func fetchPosts(matching filter: PostsViewModel.Filter) async throws -> [Post] {
    switch filter {
    case .all:
      return try await fetchAllPosts()
    case .favorites:
      return try await fetchFavoritePosts()
    case let .author(user):
      return try await fetchPosts(by: user)
    }
  }
  
  /// case .all
  func fetchAllPosts() async throws -> [Post] {
    try await fetchPosts(from: postsReference)
  }
  /// case let .author(user
  func fetchPosts(by author: User) async throws -> [Post] {
    try await fetchPosts(from: postsReference.whereField("author.id", isEqualTo: author.id))
  }
  /// case .favorites
  /// The app needs to obtain the postIDs to lookup the posts, the property isFavorite, is not stored online.
  func fetchFavoritePosts() async throws -> [Post] {
    let favoritesPostIds = try await fetchFavoritesPostIDs()
    guard !favoritesPostIds.isEmpty else { return [] }
    
    return try await postsReference
      .whereField("id", in: favoritesPostIds.map(\.uuidString))
      .order(by: "timestamp", descending: true)
      .getDocuments(as: Post.self)
      .map { post in
        post.setting(\.isFavorite, to: true)
      }
  }
  
  
  /// Whenever we retrieve posts from Firestore with fetchPosts(from:),
  /// which retrieves Posts and Favorites PostIDs
  /// we’ll know if the post is a favorite because the isFavorite property will be set. ⬇︎
  private func fetchPosts(from query: Query) async throws -> [Post] {
    let (posts, favoritesPostIDs) = try await (query.order(by: "timestamp", descending: true).getDocuments(as: Post.self),
                                               fetchFavoritesPostIDs())
    return posts.map { post in
      post.setting(\.isFavorite, to: favoritesPostIDs.contains(post.id))
    }
  }
}


// MARK: - Favorites
extension PostsRepository {
  struct Favorite: Identifiable, Codable {
    var userID: User.ID
    var postID: Post.ID
    
    var id: String { postID.uuidString + "-" + userID}
  }
  
  /// Query Firestore for ALL favorites that match USER ID
  func fetchFavoritesPostIDs() async throws -> [Post.ID] {
    return try await favoritesReference
      .whereField("userID", isEqualTo: user.id)
      .getDocuments(as: Favorite.self)
      .map(\.postID)
  }
  
  
  func favorite(_ post: Post) async throws {
    let favorite = Favorite(userID: user.id, postID: post.id)
    let documentReference = favoritesReference.document(favorite.id)
    try await documentReference.setData(from: favorite)
  }
  
  func unfavorite(_ post: Post) async throws {
    let favorite = Favorite(userID: user.id, postID: post.id)
    let documentReference = favoritesReference.document(favorite.id)
    try await documentReference.delete()
  }
  
  func toggleFavorite(_ favorite: Bool, for post: Post) async throws {
    if favorite {
      try await self.favorite(post)
    }
    else {
      try await self.unfavorite(post)
    }
  }
}




/// Extension to Post to allow to toggle favorites, basically
private extension Post {
  func setting<T>(_ keyPath: WritableKeyPath<Post, T>, to newValue: T) -> Post {
    var post = self
    post[keyPath: keyPath] = newValue
    return post
  }
}


