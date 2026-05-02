//
//  FPL Insight
//  NetworkConnectionChecker.swift
//  Developed by Md Afser Uddin
//
import Foundation
import Network

protocol NetworkConnectionChecking {
    var isConnected: Bool { get }
}

final class NetworkConnectionChecker: NetworkConnectionChecking {
    static let shared = NetworkConnectionChecker()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkConnectionChecker")
    private var latestStatus: NWPath.Status = .requiresConnection

    var isConnected: Bool {
        latestStatus == .satisfied
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.latestStatus = path.status
        }
        monitor.start(queue: queue)
    }
}
