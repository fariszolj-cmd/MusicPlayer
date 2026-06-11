import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Library")
                }
                .tag(0)

            PlayerView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Now Playing")
                }
                .tag(1)
        }
        .accentColor(.purple)
    }
}
