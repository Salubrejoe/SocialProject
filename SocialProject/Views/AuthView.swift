import SwiftUI

/*
 The app starts by creating an instance of AuthViewModel which initiates a StateDidChange 
 listener to get back a user.
 This appens in AuthService, then the user is passed, when we init(), to AuthViewModel.
 
 If there is no user, the app will present forms to Sign In or Create a new Account.
 They will be injected with a FormViewModel properly subclassed in AuthViewModel.
 [FormViewModel takes a tuple (of strings: email, password, username, ...) as Value and 
 an Action for
 when it is time to sumbit().]
 
 When the listener notifies the app with a user, the former will display the MainTabView
 which is equipped with a factory for making the right view model for displaying the list
 of posts filtered for the different screens.
 
 The factory only need a user. That comes from the listener.
 */

struct AuthView: View {
  @StateObject var viewModel = AuthViewModel()
  
  var body: some View {
    if let factory = viewModel.makeViewModelFactory() {
      MainTabView()
        .environmentObject(factory)
    } else {
      NavigationStack {
        SignInForm(viewModel: viewModel.makeSignInViewModel()) {
          NavigationLink(K.createAccount, 
                         destination: CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel()))
        }
      }
    }
  }
}

private extension AuthView {
  // MARK: - CREATE ACCOUNT FORM
  struct CreateAccountForm: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AuthViewModel.CreateAccountViewModel
    
    var body: some View {
      Form {
        TextField(K.name, text: $viewModel.name)
          .textContentType(.name)
          .textInputAutocapitalization(.words)
        TextField(K.email, text: $viewModel.email)
          .textContentType(.emailAddress)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
        SecureField(K.password, text: $viewModel.password)
          .textContentType(.newPassword)
      } footer: {
        Button(K.createAccount, action: viewModel.submit)
          .buttonStyle(.primary)
        
        Button(K.signIn, action: dismiss.callAsFunction)
          .padding()
      }
      .alert(K.createAccAlert, error: $viewModel.error)
      .disabled(viewModel.isWorking)
      .onSubmit(viewModel.submit)
    }
  }
  
  // MARK: - SIGN IN FORM
  struct SignInForm<Footer: View>: View {
    @StateObject var viewModel: AuthViewModel.SignInViewModel
    @ViewBuilder let footer: () -> Footer
    
    var body: some View {
      Form {
        TextField(K.email, text: $viewModel.email)
          .textContentType(.emailAddress)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
        SecureField(K.password, text: $viewModel.password)
          .textContentType(.password)
      } footer: {
        Button(K.signIn, action: viewModel.submit)
          .buttonStyle(.primary)
      
        footer()
          .padding()
      }
      .alert(K.signInAlert, error: $viewModel.error)
      .disabled(viewModel.isWorking)
      .onSubmit(viewModel.submit)
    }
  }
}

private extension AuthView {
  struct Form<Content: View, Footer: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer
    
    var body: some View {
      VStack {
        Text(K.basedSocial)
          .font(.title.bold())
        content()
          .padding()
          .background(Color.secondary.opacity(0.15))
          .cornerRadius(10)
        footer()
      }
      .navigationBarHidden(true)
      .padding()
    }
  }
}


// MARK: - K
private extension AuthView {
  private struct K {
    static let basedSocial    = "Based Social"
    static let name           = "Name"
    static let email          = "Email"
    static let password       = "Password"
    static let signIn         = "Sign In"
    static let createAccount  = "Create Account"
    static let signInAlert    = "Cannot Sign In"
    static let createAccAlert = "Cannot Create Account"
  }
}
