//
//  BestXIViewModelTests.swift
//  FPL InsightTests
//
//  Created by Shimanto A. on 2/5/26.
//

import Testing
@testable import FPL_Insight

@MainActor
struct BestXIViewModelTests {
    @Test func loadBestXIStoresLoadedResponse() async {
        let viewModel = BestXIViewModel(api: MockFPLInsightAPI())

        await viewModel.loadBestXI()

        guard case .loaded(let response) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }

        #expect(response.totalPredictedPoints == 84)
        #expect(response.players.first?.name == "Mohamed Salah")
    }

    @Test func loadBestXIStoresFailureMessage() async {
        let api = MockFPLInsightAPI(bestXIResult: .failure(TestError.failed))
        let viewModel = BestXIViewModel(api: api)

        await viewModel.loadBestXI()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }

        #expect(message == "Test failure")
    }
}
