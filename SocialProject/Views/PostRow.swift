import SwiftUI


struct PostRow: View {
  @ObservedObject var viewModel: PostRowViewModel
  @State private var showConfirmationDialog = false
  
  @EnvironmentObject var factory: ViewModelFactory
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      header
      if let imageURL = viewModel.imageURL {
        PostImage(url: imageURL)
      }
      titleAndContent
      footer
    }
    .padding()
    .alert(K.cannotDelete, error: $viewModel.error)
    .confirmationDialog(K.confirmation, 
                        isPresented: $showConfirmationDialog,
                        titleVisibility: .visible) { confirmDelete }
  }
}

private extension PostRow {
  
  private var header: some View {
    HStack {
      AuthorView(author: viewModel.author)
      Spacer()
      Text(viewModel.timestamp.formatted(date: .abbreviated, time: .shortened))
        .font(.caption)
    }
    .foregroundColor(.gray)
  }
  
  @ViewBuilder
  private var titleAndContent: some View {
    Text(viewModel.title)
      .font(.title3)
      .fontWeight(.semibold)
    Text(viewModel.content)
  }
  
  private var footer: some View {
    HStack {
      FavoriteButton(isFavorite: viewModel.isFavorite) { viewModel.favoritePost() }
      NavigationLink {
        CommentsList(viewModel: factory.makeCommentsViewModel(for: viewModel.post))
      } label: {
        Label(K.comments, systemImage: K.textBubble)
          .foregroundColor(.secondary)
      }
      Spacer()
      if viewModel.canDeletePost { deleteButton }
      
    }
    .labelStyle(.iconOnly)
  }
  
  private var deleteButton: some View {
    Button(role: .destructive, action: { showConfirmationDialog = true }) {
      Label(K.delete, systemImage: K.trash)
    }
  }
  
  private var confirmDelete: some View {
    Button(K.delete, role: .destructive, action: viewModel.deletePost)
  }
}

// MARK: - Image
private extension PostRow {
  struct PostImage: View {
    let url: URL
    
    var body: some View {
      AsyncImage(url: url) { image in
        image
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } placeholder: {
        Color.clear
      }
    }
  }

}


// MARK: - Favorite Button
private extension PostRow {
  struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
      Button(action: action) {
        if isFavorite {
          Label(K.removeFromFav, systemImage: K.heartFill)
        } else {
          Label(K.addToFav, systemImage: K.heart)
        }
      }
      .foregroundColor(isFavorite ? Color(.systemPink) : .gray)
      .animation(.default, value: isFavorite)
    }
  }
}

// MARK: - Author View
private extension PostRow {
  struct AuthorView: View {
    let author: User
    
    @EnvironmentObject private var factory: ViewModelFactory
    
    var body: some View {
      NavigationLink {
        PostsList(viewModel: factory.makePostsViewModel(filter: .author(author)))
      } label: {
        HStack {
          ProfileImage(url: author.imageURL)
            .frame(width: 30, height: 30)

          Text(author.name)
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }
    }
  }
}


// MARK: - K
private extension PostRow {
  private struct K {
    static let delete        = "Delete"
    static let trash         = "trash"
    static let comments      = "Comments"
    static let textBubble    = "text.bubble"
    static let cannotDelete  = "Cannot Delete Post"
    static let confirmation  = "Are you sure you want to delete this post?"
    static let removeFromFav = "Remove from Favorites"
    static let addToFav      = "Add to Favorites"
    static let heart         = "heart"
    static let heartFill     = "heart.fill"
  }
}
