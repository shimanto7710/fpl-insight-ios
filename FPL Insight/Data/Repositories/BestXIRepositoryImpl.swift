//
//  FPL Insight
//  BestXIRepositoryImpl.swift
//  Developed by Md Afser Uddin
//
struct BestXIRepositoryImpl: BestXIRepository {
    private let api: any FPLInsightAPIProtocol

    init(api: any FPLInsightAPIProtocol = FPLInsightAPI()) {
        self.api = api
    }

    func fetchBestXI() async throws -> BestXIResponse {
        try await api.fetchBestXI()
    }
}
