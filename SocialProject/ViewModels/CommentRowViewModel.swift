import SwiftUI

/// This view model is a thin wrapper around the Comment type.
/// Like the PostRowViewModel, we used dynamic member lookup,
/// meaning that we can subscript the view model as if it were a Comment.


@MainActor
@dynamicMemberLookup
class CommentRowViewModel: ObservableObject {
  typealias AsyncAction = () async throws -> Void
  subscript<T>(dynamicMember keyPath: KeyPath<Comment, T>) -> T {
    /// By making these two changes, we’ll be able to access Post properties from the PostRow like this: viewModel.content
    comment[keyPath: keyPath]
  }
  
  @Published var comment: Comment
  @Published var error: Error?
  
  private let deleteAction: AsyncAction?
  
  var canDeleteComment: Bool { deleteAction != nil }
  
  init(comment: Comment, deleteAction: AsyncAction?) {
    self.comment = comment
    self.deleteAction = deleteAction
  }
}



/// The protocol requires a var error: Error?
/// and provides a withErrorHandlingTask(perform:) method

extension CommentRowViewModel: StateManager {
  func deleteComment() {
    guard let deleteAction else {
      preconditionFailure("Cannot delete post: no delete action provided")
    }
    withStateManagingTask(perform: deleteAction)
  }
}
