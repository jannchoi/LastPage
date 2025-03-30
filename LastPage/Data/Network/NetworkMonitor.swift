//
//  NetworkMonitor.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    private var statusSubject = PassthroughSubject<Bool, Never>()

    var currentStatus: AnyPublisher<Bool, Never> {
        return statusSubject.eraseToAnyPublisher()
    }

    private init() {}

    func startNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.statusSubject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    func stopNetworkMonitor() {
        monitor.cancel()
    }
}

