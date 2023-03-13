//
//  Network.swift
//  InStock
//
//  Created by Abdullah Atkaev on 28.02.2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(Error)
}

class Network {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func get<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            }
        }

        task.resume()
    }

    func post<T: Encodable>(url: URL, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    func put<T: Encodable>(url: URL, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }

    func delete(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }

        task.resume()
    }
}
