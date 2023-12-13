import SwiftUI


struct NewPostForm: View {
  @StateObject var viewModel: FormViewModel<Post>
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    NavigationStack {
      Form {
        
        Section {
          TextField(K.title, text: $viewModel.title)
        }
        
        ImageSection(imageURL: $viewModel.imageURL)
        
        Section(K.content) {
          TextEditor(text: $viewModel.content)
            .multilineTextAlignment(.leading)
        }
        
        Button(action: viewModel.submit) { buttonLabel }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .padding()
        .listRowBackground(Color.accentColor)

      }
      .onSubmit(viewModel.submit)
      .navigationTitle(K.newPost)
    }
    .disabled(viewModel.isWorking)
    .alert(K.savingError, error: $viewModel.error)
    .onChange(of: viewModel.isWorking) { _, isFinished in
      dismissIfFinished(isFinished)
    }
  }
}

extension NewPostForm {
  @ViewBuilder
  private var buttonLabel: some View {
    if viewModel.isWorking {
      ProgressView()
    } else {
      Text(K.createPost)
    }
  }
  
  private func dismissIfFinished(_ newValue: Bool) {
    guard newValue == false, viewModel.error == nil else { return }
    dismiss()
  }
}


private extension NewPostForm {
  struct ImageSection: View {
    @Binding var imageURL: URL?
    
    var body: some View {
      Section(K.image) {
        AsyncImage(url: imageURL) { image in
          image
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } placeholder: {
          EmptyView()
        }
        ImagePickerButton(imageURL: $imageURL) {
          Label(K.chooseImage, systemImage: K.photoFill)
        }
      }
    }
  }
}



// MARK: - K
extension NewPostForm {
  private struct K {
    static let emptyStr    = ""
    static let title       = "Title"
    static let newPost     = "New Post"
    static let savingError = "Saving Error"
    static let createPost  = "Create Post"
    static let content     = "Content"
    static let image       = "Image"
    static let chooseImage = "Choose Image"
    static let photoFill   = "photo.fill"
  }
}



