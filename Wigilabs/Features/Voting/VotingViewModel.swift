//
//  VotingViewModel.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class VotingViewModel {
    private(set) var currentBreed: Breed?
    private(set) var currentImage: CatImage?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let repository: VotingRepositoryProtocol
    private var breeds: [Breed] = []
    private var lastBreedId: String?
    private var loadTask: Task<Void, Never>?

    init(repository: VotingRepositoryProtocol) {
        self.repository = repository
    }

    func loadBreedsIfNeeded() {
        guard breeds.isEmpty else { return }
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadBreedsAndFirstImage()
        }
    }

    func loadNextBreed() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadNextBreedImage()
        }
    }

    func vote(_ type: VoteType) {
        guard let breed = currentBreed, let image = currentImage else { return }
        do {
            try repository.recordVote(breed: breed, image: image, type: type)
        } catch {
            errorMessage = String(localized: "voting.error.save", defaultValue: "No se pudo guardar el voto.")
            return
        }
        loadNextBreed()
    }

    func retry() {
        if breeds.isEmpty {
            loadBreedsIfNeeded()
        } else {
            loadNextBreed()
        }
    }

    private func loadBreedsAndFirstImage() async {
        isLoading = true
        errorMessage = nil
        do {
            breeds = try await repository.fetchBreeds()
            await loadNextBreedImage()
        } catch {
            errorMessage = String(localized: "voting.error.breeds", defaultValue: "No se pudieron cargar las razas. Intenta de nuevo.")
            isLoading = false
        }
    }

    private func loadNextBreedImage(remainingAttempts: Int = 3) async {
        guard !breeds.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        errorMessage = nil

        var candidate = breeds.randomElement()
        if breeds.count > 1 {
            while candidate?.id == lastBreedId {
                candidate = breeds.randomElement()
            }
        }
        guard let breed = candidate else {
            isLoading = false
            return
        }

        do {
            let image = try await repository.resolveImage(for: breed)
            guard !Task.isCancelled else { return }
            currentBreed = breed
            currentImage = image
            lastBreedId = breed.id
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            if remainingAttempts > 1 {
                await loadNextBreedImage(remainingAttempts: remainingAttempts - 1)
            } else {
                errorMessage = String(localized: "voting.error.image", defaultValue: "No se pudo cargar la imagen de la raza. Intenta de nuevo.")
                isLoading = false
            }
        }
    }
}
