import SwiftUI

/// This view model holds a POST, a DELETE action and a FAVORITE action for the buttons.
/// The class is instanciated within the List View Model, so we can pass the POST

@MainActor
@dynamicMemberLookup
final class PostRowViewModel: ObservableObject {
  typealias AsyncAction = () async throws -> Void
  subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
    /// By making these two changes, we’ll be able to access Post properties from the PostRow like this: viewModel.content
    post[keyPath: keyPath]
  }
  
  @Published var post: Post
  @Published var error: Error?
  
  private let deleteAction   : AsyncAction?
  private let favoriteAction : AsyncAction
  
  var canDeletePost: Bool { deleteAction != nil }
  
  init(post: Post, deleteAction: AsyncAction?, favoriteAction: @escaping AsyncAction) {
    self.post = post
    self.deleteAction = deleteAction
    self.favoriteAction = favoriteAction
  }
}



/// The protocol requires a var error: Error?
/// and provides a withErrorHandlingTask(perform:) method

extension PostRowViewModel: StateManager {
  func deletePost() {
    guard let deleteAction else {  preconditionFailure("Cannot delete post: no delete action provided") }
    withStateManagingTask(perform: deleteAction)
  }
  func favoritePost() { withStateManagingTask(perform: favoriteAction) }
}
