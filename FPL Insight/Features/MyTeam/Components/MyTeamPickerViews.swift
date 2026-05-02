import SwiftUI

struct PlayerPickerView: View {
    @ObservedObject var viewModel: MyTeamViewModel
    let slot: SquadSlot

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.searchState {
                case .idle, .loading:
                    ProgressView("Loading players...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(let players):
                    List(players) { player in
                        Button {
                            viewModel.assign(player)
                        } label: {
                            PlayerPickerRow(player: player)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Unable to Load Players", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.searchPlayers()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add \(slot.title)")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: searchPrompt)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.searchPlayersDebounced()
            }
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchPlayers()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.selectedSlot = nil
                    }
                }

                if slot.player != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Remove", role: .destructive) {
                            viewModel.clearSelectedSlot()
                        }
                    }
                }
            }
        }
    }

    private var searchPrompt: String {
        if let position = slot.role.allowedPlayerPosition {
            return "Search \(position) players"
        }

        return "Search players"
    }
}

private struct PlayerPickerRow: View {
    let player: AllPlayerModel

    var body: some View {
        HStack(spacing: 12) {
            MyTeamPlayerImage(urlString: player.imageURL, fallbackColor: .green)
                .frame(width: 38, height: 38)
                .background(.green.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(player.team) | \(player.position)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("GBP \(player.price, specifier: "%.1f")m")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}
