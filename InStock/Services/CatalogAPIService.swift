//
//  CatalogAPIService.swift
//  InStock
//
//  Created by Abdullah Atkaev on 28.02.2023.
//

import Foundation

protocol CatalogAPIServiceProtocol {
    func getCatalogItems(completion: @escaping (Result<[StockItem], Error>) -> Void)
    func addCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void)
    func updateCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void)
}

class CatalogAPIService: CatalogAPIServiceProtocol {
    private let apiService: APIService<StockItem>

    init(baseURL: URL, network: Network = Network()) {
        apiService = APIService(baseURL: baseURL, network: network)
    }

    func getCatalogItems(completion: @escaping (Result<[StockItem], Error>) -> Void) {
        apiService.get(endpoint: "catalog", completion: completion)
    }

    func addCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void) {
        apiService.post(endpoint: "catalog", body: item, completion: completion)
    }

    func updateCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void) {
        apiService.put(endpoint: "catalog/\(item.id)", body: item, completion: completion)
    }

    func deleteCatalogItem(item: StockItem, completion: @escaping (Result<Void, Error>) -> Void) {
        apiService.delete(endpoint: "catalog/\(item.id)", completion: completion)
    }
}
