//
//  VotingRepository.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

protocol VotingRepositoryProtocol {
    func fetchBreeds() async throws -> [Breed]
    func resolveImage(for breed: Breed) async throws -> CatImage
    func recordVote(breed: Breed, image: CatImage, type: VoteType) throws
    func fetchVoteHistory() throws -> [VoteRecord]
}

final class VotingRepository: VotingRepositoryProtocol {
    private let apiService: CatAPIServicing
    private let voteStore: VoteStoring

    init(apiService: CatAPIServicing, voteStore: VoteStoring) {
        self.apiService = apiService
        self.voteStore = voteStore
    }

    func fetchBreeds() async throws -> [Breed] {
        try await apiService.fetchBreeds()
    }

    func resolveImage(for breed: Breed) async throws -> CatImage {
        guard let referenceImageId = breed.referenceImageId else {
            throw NetworkError.missingData
        }
        return try await apiService.fetchImage(id: referenceImageId)
    }

    func recordVote(breed: Breed, image: CatImage, type: VoteType) throws {
        try voteStore.save(breedId: breed.id, breedName: breed.name, imageId: image.id, voteType: type)
    }

    func fetchVoteHistory() throws -> [VoteRecord] {
        try voteStore.fetchAll()
    }
}
