//
//  CatListViewModel.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class CatListViewModel {
    private(set) var catImages: [CatImage] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let repository: CatCatalogRepositoryProtocol

    init(repository: CatCatalogRepositoryProtocol) {
        self.repository = repository
    }

    func loadCatsIfNeeded() {
        guard catImages.isEmpty else { return }
        Task { await loadCats() }
    }

    func reload() {
        Task { await loadCats() }
    }

    private func loadCats() async {
        isLoading = true
        errorMessage = nil
        do {
            catImages = try await repository.fetchCatImages(limit: 30)
        } catch {
            errorMessage = String(localized: "catlist.error", defaultValue: "No se pudieron cargar los gatos. Intenta de nuevo.")
        }
        isLoading = false
    }
}
