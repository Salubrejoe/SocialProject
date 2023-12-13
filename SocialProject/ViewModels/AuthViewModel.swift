import SwiftUI

/// Starts with the app.
///
/// Calls AuthService to retrieve a user.
///
/// Holds the definition of the view models for the forms.

@MainActor
final class AuthViewModel: ObservableObject {
  @Published var user: User?

  private let authService: AuthService
  
  init() {
    self.authService = AuthService()
    authService.$user.assign(to: &$user)
  }
}

extension AuthViewModel {
  /// Define the view model with the proper tuple of values
  /// Pass the tuples with empty strings in the convenience init()
  
  final class SignInViewModel: FormViewModel<(email: String, password: String)> {
    convenience init(action: @escaping Action) {
      self.init(initialValue: (email: "", password: ""), action: action)
    }
  }
  
  final class CreateAccountViewModel: FormViewModel<(name: String, email: String, password: String)> {
    convenience init(action: @escaping Action) {
      self.init(initialValue: (name: "", email: "", password: ""), action: action)
    }
  }
  
  func makeSignInViewModel() -> SignInViewModel {
    SignInViewModel(action: authService.signIn(email:password:))
    /// Since the Value types are defined with tuples, Swift maps them into function parameters automatically.
  }
  
  func makeCreateAccountViewModel() -> CreateAccountViewModel {
    CreateAccountViewModel(action: authService.createAccount(name:email:password:))
    /// Since the Value types are defined with tuples, Swift maps them into function parameters automatically.
  }
  
  func makeViewModelFactory() -> ViewModelFactory? {
    guard let user else { return nil }
    return ViewModelFactory(user: user, authService: authService)
  }
}
