import SwiftUI
import SwiftData

struct MyTeamView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MyTeamViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                FormationPickerView(
                    selectedFormation: viewModel.selectedFormation,
                    onSelect: viewModel.updateFormation
                )

                TeamPointsSummaryView(
                    fieldPoints: viewModel.fieldPredictedPoints,
                    benchPoints: viewModel.benchPredictedPoints,
                    totalPoints: viewModel.totalPredictedPoints
                )

                MyTeamPitchView(viewModel: viewModel)

                BenchView(slots: viewModel.benchSlots) { slot in
                    viewModel.openPicker(for: slot)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Team")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedSlot) { slot in
            PlayerPickerView(viewModel: viewModel, slot: slot)
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        MyTeamView()
    }
    .modelContainer(for: SavedSquadPlayer.self, inMemory: true)
}
