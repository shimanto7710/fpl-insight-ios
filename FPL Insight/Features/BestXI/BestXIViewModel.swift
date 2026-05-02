//
//  BestXIViewModel.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import Combine
import Foundation

@MainActor
final class BestXIViewModel: ObservableObject {
    @Published private(set) var state: BestXIState = .loading

    private let api: any FPLInsightAPIProtocol

    init(api: any FPLInsightAPIProtocol = FPLInsightAPI()) {
        self.api = api
    }

    func loadBestXI() async {
        state = .loading

        do {
            let bestXI = try await api.fetchBestXI()
            state = .loaded(bestXI)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

enum BestXIState {
    case loading
    case loaded(BestXIResponse)
    case failed(String)
}
