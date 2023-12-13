import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject, StateManager {
  @Published var name: String
  @Published var imageURL: URL? {
    didSet {
      imageURLDidChange(from: oldValue)
    }
  }
  @Published var error: Error?
  @Published var isWorking = false
  
  private let authService: AuthService
  
  init(user: User, authService: AuthService) {
    self.name = user.name
    self.imageURL = user.imageURL
    self.authService = authService
  }
  
  func singOut() {
    withStateManagingTask(perform: authService.signOut)
  }
  
  private func imageURLDidChange(from oldValue: URL?) {
    guard imageURL != oldValue else { return }
    withStateManagingTask { [self] in
      try await self.authService.updateProfileImage(to: self.imageURL)
    }
  }
}
