import Foundation

@MainActor
final class CommentsViewModel: ObservableObject {
  @Published var comments: Loadable<[Comment]> = .loading
  
  private let commentRepo: CommentsRepository
  
  init(commentRepo: CommentsRepository) {
    self.commentRepo = commentRepo
  }
}

extension CommentsViewModel {
  func fetchCommentsAndHandleErrorTask() {
    Task {
      do {
        comments = .loaded(try await commentRepo.fetchComments())
      }
      catch {
        print("\n[CommentsViewModel] Cannot fetch comments:\n\(error)")
        comments = .error(error)
      }
    }
  }
  
  func makeCommentRowViewModel(for comment: Comment) -> CommentRowViewModel {
    
    let deleteAction = { [weak self] in
      try await self?.commentRepo.delete(comment)
      self?.comments.value?.removeAll { $0.id == comment.id }
    }
    
    let conditionalDeleteAction = commentRepo.canDelete(comment) ? deleteAction : nil
    
    return CommentRowViewModel(comment: comment,
                               deleteAction: conditionalDeleteAction)
  }
  
  func makeNewCommentViewModel() -> FormViewModel<Comment> {
    let createAction = { [weak self] comment in
      try await self?.commentRepo.create(comment)
      self?.comments.value?.insert(comment, at: 0)
    }
    return FormViewModel(initialValue: Comment(content: "", author: commentRepo.user), action: createAction)
  }
}
