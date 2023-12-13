import SwiftUI
import FirebaseAuth

struct ProfileView: View {
  @StateObject var viewModel: ProfileViewModel
  
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        ProfileImage(url: viewModel.imageURL)
          .frame(width: 200, height: 200)
        Spacer()
        Text(viewModel.name)
          .font(.title2)
          .bold()
          .padding()
        ImagePickerButton(imageURL: $viewModel.imageURL) {
          Label(K.chooseImage, systemImage: K.photoFill)
        }
        Spacer()
      }
      .navigationTitle(K.profile)
      .toolbar { Button(K.signOut) { viewModel.singOut() } }
      .alert(K.error, error: $viewModel.error)
      .disabled(viewModel.isWorking)
    }
  }
}



// MARK: - K
private extension ProfileView {
  private struct K {
    static let signOut     = "Sign Out"
    static let chooseImage = "Choose Image"
    static let photoFill   = "photo.fill"
    static let profile     = "Profile"
    static let error       = "Error"
  }
}
