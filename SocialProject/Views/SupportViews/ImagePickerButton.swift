import SwiftUI
import UIKit


struct ImagePickerButton<Label: View>: View {
  @Binding var imageURL: URL?
  @ViewBuilder let label: () -> Label
  
  @State private var showImageSourceDialog = false
  @State private var sourceType: UIImagePickerController.SourceType?
  
  var body: some View {
    Button(action: showDialog, label: label)
      .confirmationDialog(K().chooseImage,
                          isPresented: $showImageSourceDialog,
                          actions: dialogActions)
      .fullScreenCover(item: $sourceType) { sourceType in
        ImagePickerView(sourceType: sourceType, onSelect: onSelectAction(_:))
      }
  }
}

extension ImagePickerButton {
  private func onSelectAction(_ url: URL)  { imageURL = url }
  
  @ViewBuilder
  private func dialogActions() -> some View {
    Button(K().chooseFromLibrary, action: photoLibrary)
    Button(K().takePhoto, action: camera)
    if imageURL != nil {
      Button(K().removePhoto, role: .destructive, action: removePhoto)
    }
  }
  
  private func showDialog() { showImageSourceDialog = true }
  private func photoLibrary() { sourceType = .photoLibrary }
  private func camera() { sourceType = .camera }
  private func removePhoto() { imageURL = nil }
}

private extension ImagePickerButton {
  struct ImagePickerView: UIViewControllerRepresentable {
    class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
      let view: ImagePickerView
      
      init(view: ImagePickerView) {
        self.view = view
      }
      
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

//        guard let imageURL = info[.imageURL] as? URL else { return }
//        print("ImageURL: \(imageURL)")
//        view.onSelect(imageURL)
//        view.dismiss()
        
        if let editedImage = info[.editedImage] as? UIImage,
           let imageData = editedImage.pngData(),
           let imageURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("edited_image.png") {
          do {
            try imageData.write(to: imageURL)
            view.onSelect(imageURL)
            
          } catch {
            print("Error saving edited image: \(error.localizedDescription)")
          }
        }
        view.dismiss()
      }
    }
    
    let sourceType: UIImagePickerController.SourceType
    let onSelect: (URL) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    func makeCoordinator() -> ImagePickerCoordinator {
      return ImagePickerCoordinator(view: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
      let imagePicker = UIImagePickerController()
      imagePicker.allowsEditing = true
      imagePicker.delegate = context.coordinator
      imagePicker.sourceType = sourceType
      return imagePicker
    }
    
    func updateUIViewController(_ imagePicker: UIImagePickerController, context: Context) {}
  }
}


// MARK: - CONFORMANCE TO IDENTIFIABLE
extension UIImagePickerController.SourceType: Identifiable {
  public var id: String { "\(self)" }
}




// MARK: - K
private extension ImagePickerButton {
  private struct K {
    let chooseImage = "Choose Image"
    let removePhoto = "Remove Photo"
    let chooseFromLibrary = "Choose from Library"
    let takePhoto = "Take Photo"
  }
}
