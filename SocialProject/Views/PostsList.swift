import SwiftUI

/*
 PostsViewModel makes the view models for the Row and the "New" Form.
 The signature of Posts = Loadable<[Post]> allows us to check the state of the loading process.
 */

struct PostsList: View {
  @StateObject var viewModel: PostsViewModel
  
  @State private var searchText = ""
  @State private var showNewPostForm = false
  
  var body: some View {
    Group {
      switch viewModel.posts {
      case .loading:
        ProgressView()
      case .error(let error):
        errorView(error)
      case .empty:
        emptyView
      case let .loaded(posts):
        list(of: posts)
      }
    }
    .navigationTitle(viewModel.title)
    .searchable(text: $searchText)
    .toolbar { toolbar }
    .sheet(isPresented: $showNewPostForm) { sheet }
    .onAppear { viewModel.fetchPostsAndHandleErrorTask() }
  }
}

extension PostsList {
  private var emptyView: some View {
    EmptyListView(
      title: K.noPosts,
      message: K.noPostsYet
    )
  }
  
  private func errorView(_ error: Error) -> some View {
    EmptyListView(
      title: K.cannotLoadPosts,
      message: error.localizedDescription,
      retryAction: {
        viewModel.fetchPostsAndHandleErrorTask()
      }
    )
  }
  
  private func list(of posts: [Post]) -> some View {
    ScrollView {
      ForEach(posts) { post in
        if searchText.isEmpty || post.contains(searchText) {
          PostRow(viewModel: viewModel.makePostRowViewModel(for: post))
          Divider()
            .padding(.horizontal)
        }
      }
      .searchable(text: $searchText)
      .animation(.default, value: viewModel.posts)
    }
    .scrollIndicators(.hidden)
  }
  
  private var toolbar: some View {
    Button { showNewPostForm = true }
  label: { Label(K.newPost, systemImage: K.squareAndPencil) }
  }
  
  private var sheet: some View {
    NewPostForm(viewModel: viewModel.makeNewPostViewModel())
  }
}


// MARK: - K
private extension PostsList {
  private struct K {
    static let newPost         = "New Post"
    static let squareAndPencil = "square.and.pencil"
    static let noPosts         = "No Posts"
    static let noPostsYet      = "There aren’t any posts yet."
    static let cannotLoadPosts = "Cannot Load Posts"
  }
}


