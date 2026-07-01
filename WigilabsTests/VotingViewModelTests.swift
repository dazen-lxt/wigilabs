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

    func testLoadBreedsIfNeededLoadsFirstBreedAndImage() async throws {
        let repository = FakeVotingRepository()
        let breed = makeBreed(id: "abys", imageId: "img1")
        repository.breeds = [breed]
        repository.imagesByBreedId = ["abys": makeImage(id: "img1")]

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadBreedsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.currentBreed?.id, "abys")
        XCTAssertEqual(viewModel.currentImage?.id, "img1")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testVoteRecordsVoteAndAdvancesToNextBreed() async throws {
        let repository = FakeVotingRepository()
        let breedA = makeBreed(id: "abys", imageId: "img1")
        let breedB = makeBreed(id: "beng", imageId: "img2")
        repository.breeds = [breedA, breedB]
        repository.imagesByBreedId = [
            "abys": makeImage(id: "img1"),
            "beng": makeImage(id: "img2"),
        ]

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadBreedsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        let votedBreedId = try XCTUnwrap(viewModel.currentBreed?.id)
        viewModel.vote(.like)
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(repository.recordedVotes.count, 1)
        XCTAssertEqual(repository.recordedVotes.first?.type, .like)
        XCTAssertEqual(repository.recordedVotes.first?.breed.id, votedBreedId)
        XCTAssertNotNil(viewModel.currentBreed)
    }

    func testErrorMessageSetWhenBreedsFetchFails() async throws {
        let repository = FakeVotingRepository()
        repository.breedsError = NetworkError.requestFailed(500)

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadBreedsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentBreed)
    }

    func testRetryAfterBreedsFailureRecoversOnNextAttempt() async throws {
        let repository = FakeVotingRepository()
        repository.breedsError = NetworkError.requestFailed(500)

        let viewModel = VotingViewModel(repository: repository)
        viewModel.loadBreedsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNotNil(viewModel.errorMessage)

        repository.breedsError = nil
        repository.breeds = [makeBreed(id: "abys", imageId: "img1")]
        repository.imagesByBreedId = ["abys": makeImage(id: "img1")]
        viewModel.retry()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentBreed?.id, "abys")
    }
}
