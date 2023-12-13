import Firebase
import SwiftUI

@main
struct SocialProjectApp: App {
  
  init() { FirebaseApp.configure() }
  
  var body: some Scene {
    WindowGroup {
      AuthView()
    }
  }
}
