//
//  CatAPIService.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

protocol CatAPIServicing {
    func fetchBreeds() async throws -> [Breed]
    func fetchImage(id: String) async throws -> CatImage
    func searchImages(limit: Int, hasBreeds: Bool) async throws -> [CatImage]
}

final class CatAPIService: CatAPIServicing {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = URLSessionAPIClient()) {
        self.client = client
    }

    func fetchBreeds() async throws -> [Breed] {
        try await client.request(.breeds())
    }

    func fetchImage(id: String) async throws -> CatImage {
        try await client.request(.image(id: id))
    }

    func searchImages(limit: Int, hasBreeds: Bool) async throws -> [CatImage] {
        try await client.request(.imagesSearch(limit: limit, hasBreeds: hasBreeds))
    }
}
