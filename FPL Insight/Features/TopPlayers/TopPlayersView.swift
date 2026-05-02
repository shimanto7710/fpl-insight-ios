import SwiftUI

struct TopPlayersView: View {
    @StateObject private var viewModel = TopPlayerViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading top players...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let topPlayerResponse):
                List {
                    ForEach(topPlayerResponse.players) { player in
                        PlayerRow(player: player)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentPlayer: player)
                                }
                            }
                    }

                    if viewModel.canLoadMore {
                        PaginationFooter(isLoading: viewModel.isLoadingNextPage) {
                            Task {
                                await viewModel.loadNextPage()
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }

                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))

            case .failed(let message):
                ContentUnavailableView {
                    Label("Unable to Load Top Players", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.fetchTopPlayers()
                        }
                    }
                }
            }
        }
        .navigationTitle("Top Players")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchTopPlayers()
        }
        .refreshable {
            await viewModel.fetchTopPlayers()
        }
    }
}

private struct PaginationFooter: View {
    let isLoading: Bool
    let loadMore: () -> Void

    var body: some View {
        HStack {
            Spacer()

            if isLoading {
                ProgressView()
            } else {
                Button("Load more", action: loadMore)
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

private struct PlayerRow: View {
    let player: TopPlayer

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()

                default:
                    Image(systemName: "figure.soccer")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
            .frame(width: 36, height: 36)
            .background(.tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)

                Text("\(player.team) | \(player.position)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(player.totalPoints)")
                .font(.headline)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    private var imageURL: URL? {
        guard let imageURL = player.imageURL else { return nil }
        return URL(string: imageURL)
    }
}

#Preview {
    NavigationStack {
        TopPlayersView()
    }
}
