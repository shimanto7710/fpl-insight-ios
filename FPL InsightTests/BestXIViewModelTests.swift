//
//  FPL Insight
//  BestXIViewModelTests.swift
//  Developed by Md Afser Uddin
//
import Testing
@testable import FPL_Insight

@MainActor
struct BestXIViewModelTests {
    @Test func startsWithLoadingState() {
        let viewModel = BestXIViewModel(fetchBestXIUseCase: MockFetchBestXIUseCase())

        guard case .loading = viewModel.state else {
            Issue.record("Expected loading state")
            return
        }
    }

    @Test func loadBestXIStoresLoadedResponse() async {
        let useCase = MockFetchBestXIUseCase()
        let viewModel = BestXIViewModel(fetchBestXIUseCase: useCase)

        await viewModel.loadBestXI()

        #expect(useCase.executeCallCount == 1)

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

        #expect(useCase.executeCallCount == 1)

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }

        #expect(message == "Test failure")
    }
}
