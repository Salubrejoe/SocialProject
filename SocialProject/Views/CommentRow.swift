import SwiftUI

struct CommentRow: View {
  @ObservedObject var viewModel: CommentRowViewModel
  @State private var showConfirmationDialog = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        authorName
        Spacer()
        timestamp
      }
      content
    }
    .padding(5)
    .swipeActions(content: swipeToDelete)
    .confirmationDialog(K.confirmation,
                        isPresented: $showConfirmationDialog,
                        titleVisibility: .visible) { confirmDelete }
  }
}

extension CommentRow {
  private var authorName: some View {
    Text(viewModel.author.name)
      .font(.subheadline)
      .fontWeight(.semibold)
  }
  
  private var timestamp: some View {
    Text(viewModel.timestamp.formatted())
      .foregroundColor(.gray)
      .font(.caption)
  }
  
  private var content: some View {
    Text(viewModel.content)
      .font(.headline)
      .fontWeight(.regular)
  }
  
  @ViewBuilder
  private func swipeToDelete() -> some View {
    if viewModel.canDeleteComment {
      Button(role: .destructive) {
//        showConfirmationDialog = true
        viewModel.deleteComment()
      } label: {
        Label(K.delete, systemImage: K.trash)
      }
    }
  }
  
  private var confirmDelete: some View {
    Button(K.delete, role: .destructive) {
      viewModel.deleteComment()
    }
  }
}



// MARK: - K
private extension CommentRow {
  private struct K {
    static let delete        = "Delete"
    static let trash         = "trash"
    static let confirmation  = "Are you sure you want to delete this post?"
  }
}
