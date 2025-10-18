import SwiftUI
import FirebaseCore

@main
struct YourApp: App {
  
  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 900, minHeight: 700)
    }
  }
}
