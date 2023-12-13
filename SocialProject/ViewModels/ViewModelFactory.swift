import SwiftUI

/// Simple class that is initialized with a User and it's responsible for creating
/// the correct view model for the lists given the filter.

@MainActor
final class ViewModelFactory: ObservableObject {
  
  private let user: User
  private let authService: AuthService
  
  init(user: User, authService: AuthService) {
    self.user = user
    self.authService = authService
  }
  
  func makePostsViewModel(filter: PostsViewModel.Filter = .all) -> PostsViewModel {
    PostsViewModel(filter: filter, postRepo: PostsRepository(user: user))
  }
  
  func makeCommentsViewModel(for post: Post) -> CommentsViewModel {
    CommentsViewModel(commentRepo: CommentsRepository(user: user, post: post))
  }
  
  func makeProfileViewModel() -> ProfileViewModel {
    ProfileViewModel(user: user, authService: authService)
  }
}
