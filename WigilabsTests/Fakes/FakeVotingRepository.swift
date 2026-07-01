//
//  FakeVotingRepository.swift
//  WigilabsTests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import Foundation
@testable import Wigilabs

final class FakeVotingRepository: VotingRepositoryProtocol {
    var breeds: [Breed] = []
    var imagesByBreedId: [String: CatImage] = [:]
    var recordedVotes: [(breed: Breed, image: CatImage, type: VoteType)] = []
    var breedsError: Error?
    var imageError: Error?
    var recordVoteError: Error?

    func fetchBreeds() async throws -> [Breed] {
        if let breedsError { throw breedsError }
        return breeds
    }

    func resolveImage(for breed: Breed) async throws -> CatImage {
        if let imageError { throw imageError }
        guard let image = imagesByBreedId[breed.id] else {
            throw NetworkError.missingData
        }
        return image
    }

    func recordVote(breed: Breed, image: CatImage, type: VoteType) throws {
        if let recordVoteError { throw recordVoteError }
        recordedVotes.append((breed, image, type))
    }

    func fetchVoteHistory() throws -> [VoteRecord] {
        []
    }
}
