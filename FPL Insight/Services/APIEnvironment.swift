//
//  FPL Insight
//  APIEnvironment.swift
//  Developed by Md Afser Uddin
//
enum APIEnvironment {
    case aws
    case local

    var baseURL: String {
        switch self {
        case .aws:
            "http://51.102.204.13:8000"
        case .local:
            "http://127.0.0.1:8000"
        }
    }
}

enum AppConfiguration {
    static let apiEnvironment: APIEnvironment = .aws
}
