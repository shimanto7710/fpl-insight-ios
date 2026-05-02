import Combine
import Foundation

@MainActor
final class BestXIViewModel: ObservableObject {
    @Published private(set) var state: BestXIState = .loading

    private let fetchBestXIUseCase: any FetchBestXIUseCaseProtocol

    init(fetchBestXIUseCase: any FetchBestXIUseCaseProtocol = FetchBestXIUseCase()) {
        self.fetchBestXIUseCase = fetchBestXIUseCase
    }

    func loadBestXI() async {
        state = .loading

        do {
            let bestXI = try await fetchBestXIUseCase.execute()
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
