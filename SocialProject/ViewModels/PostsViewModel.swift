import SwiftUI

/// The final class holds the POSTS being currently displayed and is instantiated with a FILTER.
/// It gets the posts through the POSTSREPO, which is passed equipped also of a user.
///
/// Responsibilities:
/// 1. Holds the Task that incapsultates the logic of Fetching the right Posts.
/// 2. Makes view models for the Post Row and the New Post Form.


@MainActor
final class PostsViewModel: ObservableObject {
  enum Filter { case all, favorites, author(User) }
  
  @Published var posts : Loadable<[Post]> = .loading
  
  private let filter: Filter
  private let postsRepo: PostsRepository
  
  init(filter: Filter = .all, postRepo: PostsRepository) {
    self.filter = filter
    self.postsRepo = postRepo
  }
  
  var title: String {
    switch filter {
    case .all:
      return "Posts"
    case .favorites:
      return "Favorites"
    case let .author(user):
      return "\(user.name)'s Posts"
    }
  }
}


extension PostsViewModel {
  func fetchPostsAndHandleErrorTask() {
    Task {
      do {
        posts = .loaded(try await postsRepo.fetchPosts(matching: filter))
      }
      catch {
        posts = .error(error)
      }
    }
  }
  
  func makePostRowViewModel(for post: Post) -> PostRowViewModel {
    /// Passing POST and ACTIONS to the PostRow
    
    let deleteAction = { [weak self] in
      try await self?.postsRepo.delete(post)
      self?.posts.value?.removeAll { $0.id == post.id }
    }
    
    let favoriteAction = { [weak self] in
      let newValue = !post.isFavorite
      try await self?.postsRepo.toggleFavorite(newValue, for: post)
      guard let index = self?.posts.value?.firstIndex(of: post) else { return }
      self?.posts.value?[index].isFavorite = newValue
    }
    
    let conditionalDeleteAction = postsRepo.canDelete(post) ? deleteAction : nil
    
    return PostRowViewModel(post: post,
                            deleteAction: conditionalDeleteAction,
                            favoriteAction: favoriteAction)
  }
  
  func makeNewPostViewModel() -> FormViewModel<Post> {
    return FormViewModel(initialValue: Post(title: "", content: "", author: postsRepo.user), action: { [weak self] post in
      try await self?.postsRepo.create(post)
      self?.posts.value?.insert(post, at: 0)
    }) 
  }
}


