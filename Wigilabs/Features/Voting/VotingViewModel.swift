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
    private(set) var deck: [VotingCard] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let repository: VotingRepositoryProtocol
    private let deckTargetSize = 2
    private var breeds: [Breed] = []
    private var loadTask: Task<Void, Never>?

    init(repository: VotingRepositoryProtocol) {
        self.repository = repository
    }

    var currentCard: VotingCard? { deck.first }
    var nextCard: VotingCard? { deck.count > 1 ? deck[1] : nil }

    func loadIfNeeded() {
        guard deck.isEmpty else { return }
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadBreedsAndFillDeck()
        }
    }

    func vote(_ type: VoteType) {
        guard let card = deck.first else { return }
        do {
            try repository.recordVote(breed: card.breed, image: card.image, type: type)
        } catch {
            errorMessage = String(localized: "voting.error.save", defaultValue: "No se pudo guardar el voto.")
            return
        }
        deck.removeFirst()
        topUpDeck()
    }

    func retry() {
        if breeds.isEmpty {
            loadIfNeeded()
        } else {
            topUpDeck()
        }
    }

    private func loadBreedsAndFillDeck() async {
        isLoading = true
        errorMessage = nil
        do {
            breeds = try await repository.fetchBreeds()
            await fillDeck()
        } catch {
            errorMessage = String(localized: "voting.error.breeds", defaultValue: "No se pudieron cargar las razas. Intenta de nuevo.")
        }
        isLoading = false
    }

    private func topUpDeck() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.fillDeck()
            self?.isLoading = false
        }
    }

    private func fillDeck(remainingAttempts: Int = 3) async {
        guard !breeds.isEmpty else { return }
        isLoading = true

        while deck.count < deckTargetSize {
            guard let breed = nextRandomBreed() else { break }
            do {
                let image = try await repository.resolveImage(for: breed)
                guard !Task.isCancelled else { return }
                deck.append(VotingCard(breed: breed, image: image))
                errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                if remainingAttempts > 1 {
                    await fillDeck(remainingAttempts: remainingAttempts - 1)
                    return
                } else if deck.isEmpty {
                    errorMessage = String(localized: "voting.error.image", defaultValue: "No se pudo cargar la imagen de la raza. Intenta de nuevo.")
                }
                return
            }
        }
    }

    private func nextRandomBreed() -> Breed? {
        guard !breeds.isEmpty else { return nil }
        let deckBreedIds = Set(deck.map(\.breed.id))
        let candidates = breeds.filter { !deckBreedIds.contains($0.id) }
        return (candidates.isEmpty ? breeds : candidates).randomElement()
    }
}
