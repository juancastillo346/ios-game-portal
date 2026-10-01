import SwiftUI

@main struct GamePortalApp: App {
    @StateObject private var store = PortalStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).tint(Palette.teal)
                .preferredColorScheme(.light)
                .alert("Storage needs attention", isPresented: Binding(get: { store.storageError != nil }, set: { if !$0 { store.storageError = nil } })) {
                    Button("OK") { store.storageError = nil }
                } message: { Text(store.storageError ?? "") }
        }
    }
}

enum Palette {
    static let ink = Color(red: 0.07, green: 0.16, blue: 0.22)
    static let teal = Color(red: 0.02, green: 0.43, blue: 0.43)
    static let paper = Color(red: 0.96, green: 0.96, blue: 0.93)
    static let orange = Color(red: 0.84, green: 0.30, blue: 0.17)
}

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity).padding(17)
        }.buttonStyle(.plain).foregroundStyle(.white).background(Palette.teal, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct RootView: View {
    @EnvironmentObject var store: PortalStore
    var body: some View {
        if store.guest.isEmpty { WelcomeView() }
        else {
            TabView {
                NavigationStack { DiscoverView() }.tabItem { Label("Discover", systemImage: "square.grid.2x2") }
                NavigationStack { MatchesView() }.tabItem { Label("My Matches", systemImage: "rectangle.stack") }
            }
        }
    }
}

struct WelcomeView: View {
    @EnvironmentObject var store: PortalStore
    @State private var name = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Label("GAMEPORTAL", systemImage: "circle.hexagongrid.fill").font(.caption.bold()).tracking(3)
                Spacer(minLength: 35)
                HStack(spacing: 16) {
                    Text("×").foregroundStyle(Palette.teal)
                    Text("○").foregroundStyle(Palette.orange)
                }.font(.system(size: 100, weight: .medium, design: .rounded))
                Text("Good games.\nSame table.").font(.system(size: 46, weight: .bold, design: .rounded))
                Text("A little friendly competition, wherever you are. Pick a game and pass the phone.")
                    .font(.title3).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 12) {
                    Text("WHAT SHOULD WE CALL YOU?").font(.caption.bold()).tracking(1)
                    TextField("Your name", text: $name).textContentType(.nickname).padding().background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityIdentifier("guestName")
                    PrimaryButton(title: "Play as guest  →") {
                        store.guest = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Player 1" : String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(30))
                        store.save()
                    }
                }
                Label("Local play · No account needed", systemImage: "iphone").font(.footnote).foregroundStyle(.secondary)
            }.padding(28).foregroundStyle(Palette.ink)
        }.background(Palette.paper)
    }
}

struct DiscoverView: View {
    @EnvironmentObject var store: PortalStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("YOUR POCKET GAME ROOM").font(.caption2.bold()).tracking(2)
                    Spacer()
                    Image(systemName: "circle.hexagongrid.fill").font(.title2)
                }.foregroundStyle(Palette.teal)
                Text("Your move,\n\(store.guest).").font(.system(size: 38, weight: .bold, design: .rounded))
                Text("Find a little time to play.").foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Label("THE CLASSIC", systemImage: "sparkle").font(.caption.bold()).tracking(1)
                        Spacer()
                        Text("01").font(.system(.title2, design: .monospaced))
                    }
                    HStack {
                        Spacer()
                        Text("×").foregroundStyle(Color(red: 0.62, green: 0.87, blue: 0.75))
                        Text("○").foregroundStyle(Color(red: 1, green: 0.68, blue: 0.48))
                        Spacer()
                    }.font(.system(size: 96, weight: .semibold, design: .rounded)).accessibilityHidden(true)
                    Text("Tic-Tac-Toe").font(.system(.largeTitle, design: .rounded).bold())
                    Text("Two players. Nine squares. One good rivalry.").foregroundStyle(.white.opacity(0.8))
                    HStack { Label("2 players", systemImage: "person.2"); Spacer(); Label("~2 min", systemImage: "clock") }.font(.subheadline)
                    NavigationLink { SetupView() } label: {
                        HStack { Text("Choose mode"); Spacer(); Image(systemName: "arrow.right") }
                            .font(.headline).padding(18).foregroundStyle(Palette.ink).background(Palette.paper, in: RoundedRectangle(cornerRadius: 15))
                    }
                }.padding(24).foregroundStyle(.white).background(Palette.ink, in: RoundedRectangle(cornerRadius: 28))
                Label("Ready offline", systemImage: "checkmark.circle.fill").font(.subheadline.bold()).foregroundStyle(Palette.teal)
                Text("This starter includes one bundled game. Matches stay on this device, ready whenever you are.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }.padding(24)
        }.background(Palette.paper).navigationTitle("Discover").navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupView: View {
    @EnvironmentObject var store: PortalStore
    @State private var first = ""
    @State private var second = "Player 2"
    @State private var created: UUID?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Make room\nfor two.").font(.system(size: 36, weight: .bold, design: .rounded))
                VStack(alignment: .leading, spacing: 12) {
                    Label("Pass-and-play", systemImage: "iphone.gen3.radiowaves.left.and.right").font(.title3.bold())
                    Text("Share this phone. After each move, pass it to the other player.").foregroundStyle(.secondary)
                    Label("Works offline", systemImage: "checkmark.circle.fill").foregroundStyle(Palette.teal).font(.subheadline)
                }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20))
                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYERS").font(.caption.bold()).tracking(2)
                    TextField("Player 1 · X", text: $first).accessibilityIdentifier("firstPlayer")
                    Divider()
                    TextField("Player 2 · O", text: $second).accessibilityIdentifier("secondPlayer")
                }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20))
                PrimaryButton(title: "Start match  →") {
                    created = store.create(first: clean(first, fallback: store.guest), second: clean(second, fallback: "Player 2"))
                }.disabled(created != nil)
                Text("Online matches and invitations will be added when the shared service is connected.").font(.footnote).foregroundStyle(.secondary)
            }.padding(24)
        }.background(Palette.paper).navigationTitle("New match").navigationBarTitleDisplayMode(.inline)
            .onAppear { if first.isEmpty { first = store.guest } }
            .navigationDestination(item: $created) { id in MatchView(id: id) }
    }
    private func clean(_ value: String, fallback: String) -> String {
        let result = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? fallback : String(result.prefix(30))
    }
}

struct MatchesView: View {
    @EnvironmentObject var store: PortalStore
    @State private var filter = "Active"
    private var filtered: [Match] { store.matches.filter { filter == "Finished" ? $0.isOver : !$0.isOver }.sorted { $0.updated > $1.updated } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pick up where\nyou left off.").font(.system(size: 34, weight: .bold, design: .rounded))
                Picker("Matches", selection: $filter) { Text("Active").tag("Active"); Text("Finished").tag("Finished") }.pickerStyle(.segmented)
                if filtered.isEmpty {
                    ContentUnavailableView(filter == "Active" ? "Your table is open" : "No finished matches", systemImage: "rectangle.stack", description: Text(filter == "Active" ? "Start a match from Discover. Your progress will be saved here." : "Complete a game to see its result here."))
                }
                ForEach(filtered) { match in
                    NavigationLink { MatchView(id: match.id) } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack { Text("Tic-Tac-Toe").font(.title3.bold()); Spacer(); Image(systemName: "chevron.right") }
                            Text(match.names.joined(separator: " vs. ")).foregroundStyle(.secondary)
                            HStack {
                                Text(match.status).font(.subheadline.bold()).foregroundStyle(Palette.teal)
                                Spacer()
                                Text("LOCAL").font(.caption2.bold()).tracking(1)
                            }
                        }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain)
                }
                NavigationLink { SetupView() } label: { Label("New match", systemImage: "plus.circle.fill").font(.headline).frame(maxWidth: .infinity).padding() }
            }.padding(24)
        }.background(Palette.paper).navigationTitle("My Matches").navigationBarTitleDisplayMode(.inline)
    }
}

struct MatchView: View {
    let id: UUID
    @EnvironmentObject var store: PortalStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmHide = false
    var body: some View {
        Group {
            if let match = store.matches.first(where: { $0.id == id }) {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Label("LOCAL MATCH", systemImage: "iphone").font(.caption.bold())
                            Spacer()
                            Label("On this device", systemImage: "internaldrive").font(.caption)
                        }.foregroundStyle(.secondary)
                        Text(match.status).font(.system(.title, design: .rounded).bold()).multilineTextAlignment(.center)
                        HStack {
                            player(match.names[0], mark: "X", active: !match.isOver && match.turn == 0)
                            Text("vs").font(.caption).foregroundStyle(.secondary)
                            player(match.names[1], mark: "O", active: !match.isOver && match.turn == 1)
                        }
                        if match.awaitingHandoff && !match.isOver {
                            VStack(spacing: 22) {
                                Image(systemName: "hand.raised.fill").font(.system(size: 48)).foregroundStyle(Palette.teal)
                                Text("Pass the phone to\n\(match.names[match.turn])").font(.title2.bold()).multilineTextAlignment(.center)
                                Text("The board is hidden until the next player is ready.").foregroundStyle(.secondary).multilineTextAlignment(.center)
                                PrimaryButton(title: "I’m \(match.names[match.turn]) · Continue") { store.reveal(id: id) }
                            }.padding(24).frame(minHeight: 340).background(.white, in: RoundedRectangle(cornerRadius: 24))
                        } else {
                            GameWebView(match: match) { cell, player in store.move(id: id, cell: cell, player: player) }
                                .frame(height: 350).clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        if match.isOver {
                            Label(match.winner == nil ? "A well-matched pair." : "Nicely played!", systemImage: "flag.checkered").font(.headline)
                            Button("Hide finished match", role: .destructive) { confirmHide = true }.padding()
                        } else {
                            Text("Three in a row wins. You can leave this screen and resume from My Matches.").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        }
                    }.padding(24)
                }
            } else { ContentUnavailableView("Match unavailable", systemImage: "rectangle.stack") }
        }.background(Palette.paper).navigationTitle("Tic-Tac-Toe").navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Hide this finished match from this device?", isPresented: $confirmHide, titleVisibility: .visible) {
                Button("Hide match", role: .destructive) { store.hide(id: id); dismiss() }
            }
    }
    private func player(_ name: String, mark: String, active: Bool) -> some View {
        VStack(spacing: 6) {
            Text(mark).font(.title2.bold()).foregroundStyle(mark == "X" ? Palette.teal : Palette.orange)
            Text(name).font(.subheadline.bold()).lineLimit(2)
        }.frame(maxWidth: .infinity).padding(12).background(active ? Palette.teal.opacity(0.10) : .white, in: RoundedRectangle(cornerRadius: 16))
    }
}
