import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PatchManagerView()
                .tabItem {
                    Label("Bo Patch", systemImage: "bolt.badge.automatic.fill")
                }
            
            FileExplorerView()
                .tabItem {
                    Label("Quan Ly File", systemImage: "folder.fill")
                }
        }
        .accentColor(.purple)
    }
}
