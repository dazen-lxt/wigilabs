//
//  CatCatalogRepository.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

protocol CatCatalogRepositoryProtocol {
    func fetchCatImages(limit: Int) async throws -> [CatImage]
}

final class CatCatalogRepository: CatCatalogRepositoryProtocol {
    private let apiService: CatAPIServicing

    init(apiService: CatAPIServicing) {
        self.apiService = apiService
    }

    func fetchCatImages(limit: Int) async throws -> [CatImage] {
        try await apiService.searchImages(limit: limit, hasBreeds: true)
    }
}
