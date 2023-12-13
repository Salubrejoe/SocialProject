import SwiftUI



struct EmptyListView: View {
  let title: String
  let message: String
  var retryAction: (() -> Void)?
  
  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Text(title)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
      Text(message)
      if let retryAction = retryAction {
        Button(action: retryAction) {
          Text("Try Again")
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary))
        }
        .padding(.top)
      }
    }
    .font(.subheadline)
    .multilineTextAlignment(.center)
    .foregroundColor(.secondary)
    .padding()
  }
}
