import SwiftUI

struct CommentsList: View {
  @StateObject var viewModel: CommentsViewModel
  
  var body: some View {
    Group {
      switch viewModel.comments {
      case .loading:
        ProgressView()
      case let .error(error):
        errorView(error)
      case .empty:
        emptyView()
      case let .loaded(comments):
        list(of: comments)
      }
      
      Spacer()
      NewCommentForm(viewModel: viewModel.makeNewCommentViewModel())
        .padding()
        .frame(height: 65)
    }
    .navigationTitle(K.comments)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.fetchCommentsAndHandleErrorTask()
    }
  }
}

extension CommentsList {
  private func errorView(_ error: Error) -> some View {
    EmptyListView(
      title: K.cannotLoadComments,
      message: error.localizedDescription,
      retryAction: {
        viewModel.fetchCommentsAndHandleErrorTask()
      }
    )
  }
  
  private func emptyView() -> some View {
    EmptyListView(
      title: K.noComments,
      message: K.beFirstToLeaveComment
    )
  }
  
  private func list(of comments: [Comment]) -> some View {
    List(comments) { comment in
      CommentRow(viewModel: viewModel.makeCommentRowViewModel(for: comment))
    }
    .animation(.default, value: comments)
  }
}

private extension CommentsList {
  struct NewCommentForm: View {
    @StateObject var viewModel: FormViewModel<Comment>
    
    var body: some View {
      HStack {
        TextField(K.comment, text: $viewModel.content)
        Button(action: viewModel.submit) {
          if viewModel.isWorking {
            ProgressView()
          } else {
            Label(K.post, systemImage: K.paperplane)
              .labelStyle(.iconOnly)
              .imageScale(.large)
          }
        }
      }
      .alert(K.cannotPostComments, error: $viewModel.error)
      .animation(.default, value: viewModel.isWorking)
      .disabled(viewModel.isWorking)
      .onSubmit {
        viewModel.content = ""
        viewModel.submit()
      }
    }
  }
}


// MARK: - K
private extension CommentsList {
  private struct K {
    static let post       = "Post"
    static let paperplane = "paperplane"
    static let comments   = "Comments"
    static let comment    = "Comment"
    static let noComments = "No Comments"
    static let cannotLoadComments    = "Cannot Load Comments"
    static let cannotPostComments    = "Cannot Post Comments"
    static let beFirstToLeaveComment = "Be the first to leave a comment."
  }
}
