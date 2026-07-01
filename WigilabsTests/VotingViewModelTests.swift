//
//  VotingViewModelTests.swift
//  WigilabsTests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import XCTest
@testable import Wigilabs

@MainActor
final class VotingViewModelTests: XCTestCase {
    private func makeBreed(id: String, imageId: String) -> Breed {
        Breed(id: id, name: id.capitalized, temperament: nil, origin: nil, description: nil, referenceImageId: imageId)
    }

    private func makeImage(id: String) -> CatImage {
        CatImage(id: id, url: "https://example.com/\(id).jpg", width: 100, height: 100, breeds: nil)
    }

    func testLoadIfNeededFillsDeckWithCurrentAndNextCard() async throws {
        let repository = FakeVotingRepository()
        let breedA = makeBreed(id: "abys", imageId: "img1")
        let breedB = makeBreed(id: "beng", imageId: "img2")
        repository.breeds = [breedA, breedB]
        repository.imagesByBreedId = [
            "abys": makeImage(id: "img1"),
            "beng": makeImage(id: "img2"),
        ]

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNotNil(viewModel.currentCard)
        XCTAssertNotNil(viewModel.nextCard)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testVoteRecordsVoteAndAdvancesToNextCard() async throws {
        let repository = FakeVotingRepository()
        let breedA = makeBreed(id: "abys", imageId: "img1")
        let breedB = makeBreed(id: "beng", imageId: "img2")
        repository.breeds = [breedA, breedB]
        repository.imagesByBreedId = [
            "abys": makeImage(id: "img1"),
            "beng": makeImage(id: "img2"),
        ]

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        let votedBreedId = try XCTUnwrap(viewModel.currentCard?.breed.id)
        let upcomingBreedId = viewModel.nextCard?.breed.id
        viewModel.vote(.like)
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(repository.recordedVotes.count, 1)
        XCTAssertEqual(repository.recordedVotes.first?.type, .like)
        XCTAssertEqual(repository.recordedVotes.first?.breed.id, votedBreedId)
        XCTAssertNotNil(viewModel.currentCard)
        if let upcomingBreedId {
            XCTAssertEqual(viewModel.currentCard?.breed.id, upcomingBreedId)
        }
    }

    func testErrorMessageSetWhenBreedsFetchFails() async throws {
        let repository = FakeVotingRepository()
        repository.breedsError = NetworkError.requestFailed(500)

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentCard)
    }

    func testRetryAfterBreedsFailureRecoversOnNextAttempt() async throws {
        let repository = FakeVotingRepository()
        repository.breedsError = NetworkError.requestFailed(500)

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNotNil(viewModel.errorMessage)

        repository.breedsError = nil
        repository.breeds = [makeBreed(id: "abys", imageId: "img1")]
        repository.imagesByBreedId = ["abys": makeImage(id: "img1")]
        viewModel.retry()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentCard?.breed.id, "abys")
    }
}
