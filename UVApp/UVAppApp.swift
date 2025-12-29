import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct UVAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
