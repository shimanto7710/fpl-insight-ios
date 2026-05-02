import Testing
@testable import FPL_Insight

@MainActor
struct BestXIViewModelTests {
    @Test func loadBestXIStoresLoadedResponse() async {
        let viewModel = BestXIViewModel(fetchBestXIUseCase: MockFetchBestXIUseCase())

        await viewModel.loadBestXI()

        guard case .loaded(let response) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }

        #expect(response.totalPredictedPoints == 84)
        #expect(response.players.first?.name == "Mohamed Salah")
    }

    @Test func loadBestXIStoresFailureMessage() async {
        let useCase = MockFetchBestXIUseCase(result: .failure(TestError.failed))
        let viewModel = BestXIViewModel(fetchBestXIUseCase: useCase)

        await viewModel.loadBestXI()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }

        #expect(message == "Test failure")
    }
}
