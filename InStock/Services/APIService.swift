//
//  APIService.swift
//  InStock
//
//  Created by Abdullah Atkaev on 28.02.2023.
//

import Foundation

class APIService<T: Codable> {
    private let baseURL: URL
    private let network: Network

    init(baseURL: URL, network: Network = Network()) {
        self.baseURL = baseURL
        self.network = network
    }

    func get(endpoint: String, completion: @escaping (Result<[T], Error>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)

        network.get(url: url) { (result: Result<[T], Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func post(endpoint: String, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)

        network.post(url: url, body: body) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func put(endpoint: String, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)

        network.put(url: url, body: body) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func delete(endpoint: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)

        network.delete(url: url) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
