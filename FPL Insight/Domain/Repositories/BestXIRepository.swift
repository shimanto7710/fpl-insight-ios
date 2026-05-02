//
//  FPL Insight
//  BestXIRepository.swift
//  Developed by Md Afser Uddin
//
protocol BestXIRepository {
    func fetchBestXI() async throws -> BestXIResponse
}
