import SwiftUI

/*
 The factory creates the appropriate view model.
 It needs only a user, which is getting from the
 parent view, and a filter.
 */

struct MainTabView: View {
  @EnvironmentObject var factory: ViewModelFactory
  
  var body: some View {
    TabView {
      NavigationStack {
        PostsList(viewModel: factory.makePostsViewModel())
      }
      .tabItem { Label(K.posts, systemImage: K.listDash) }
      NavigationStack {
        PostsList(viewModel: factory.makePostsViewModel(filter: .favorites))
      }
      .tabItem { Label(K.favorites, systemImage: K.heartFill) }
      ProfileView(viewModel: factory.makeProfileViewModel())
        .tabItem {
          Label(K.profile, systemImage: K.person)
        }
    }
  }
}


// MARK: - K
private extension MainTabView {
  private struct K {
    static let posts     = "posts"
    static let listDash  = "list.dash"
    static let favorites = "Favorites"
    static let heartFill = "heart.fill"
    static let profile   = "Profile"
    static let person    = "person"
  }
}
