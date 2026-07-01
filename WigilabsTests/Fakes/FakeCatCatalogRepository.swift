//
//  FakeCatCatalogRepository.swift
//  WigilabsTests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import Foundation
@testable import Wigilabs

final class FakeCatCatalogRepository: CatCatalogRepositoryProtocol {
    var images: [CatImage] = []
    var error: Error?

    func fetchCatImages(limit: Int) async throws -> [CatImage] {
        if let error { throw error }
        return images
    }
}
