import SwiftUI
import FirebaseAuth

/// First up when lunching the app, does:
///
/// 1. Assign a listener to StatsDidChange, get back a user, map to self.user
/// 2. Host FirebaseAuth functions for creating account, signin in and out


@MainActor
final class AuthService: ObservableObject {
  @Published var user: User?
  
  private let auth = Auth.auth()
  private var listener: AuthStateDidChangeListenerHandle?
  
  init() {
    listener = auth.addStateDidChangeListener { [weak self] _, user in
      self?.user = user.map(User.init(from:))
    }
  }
  
  func createAccount(name: String, email: String, password: String) async throws {
    
    /// Create a user with EMAIL and PASSWORD
    let authDataResult = try await auth.createUser(withEmail: email, password: password)
    
    /// Using updateProfile defined in this file below, we pass NAME to both the cloud profile and the self.user
    try await authDataResult.user.updateProfile(\.displayName, to: name)
    user?.name = name
  }
  
  func signIn(email: String, password: String) async throws {
    try await auth.signIn(withEmail: email, password: password)
  }
  
  func signOut() throws {
    try auth.signOut()
  }
  
  // TODO: PASSWORD VALIDATION
  
  func updateProfileImage(to imageFileURL: URL?) async throws {
    guard let user = auth.currentUser else { preconditionFailure("Nil User") }
    guard let imageFileURL else {
      try await user.updateProfile(\.photoURL, to: nil)
      if let photoURL = user.photoURL {
        try await StorageFile.atURL(photoURL).delete()
      }
      return
    }
    async let newPhotoURL = StorageFile 
      .with(namespace: "users", identifier: user.uid)
      .putFile(from: imageFileURL)
      .getDownloadURL()
    
    try await user.updateProfile(\.photoURL, to: newPhotoURL)
  }
}


// MARK: - Ext FirAuth.User
private extension FirebaseAuth.User {
  
  /// Function set up in order to update a key path of the Firebase User object with a new value.
  func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
    var profileChangeRequest = createProfileChangeRequest()
    profileChangeRequest[keyPath: keyPath] = newValue
    try await profileChangeRequest.commitChanges()
  }
}
