protocol FetchBestXIUseCaseProtocol {
    func execute() async throws -> BestXIResponse
}

struct FetchBestXIUseCase: FetchBestXIUseCaseProtocol {
    private let repository: any BestXIRepository

    init(repository: any BestXIRepository = BestXIRepositoryImpl()) {
        self.repository = repository
    }

    func execute() async throws -> BestXIResponse {
        try await repository.fetchBestXI()
    }
}
