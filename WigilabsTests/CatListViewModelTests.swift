//
//  CatListViewModelTests.swift
//  WigilabsTests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import XCTest
@testable import Wigilabs

@MainActor
final class CatListViewModelTests: XCTestCase {
    private func makeImage(id: String) -> CatImage {
        CatImage(id: id, url: "https://example.com/\(id).jpg", width: 100, height: 100, breeds: nil)
    }

    func testLoadCatsIfNeededPopulatesImages() async throws {
        let repository = FakeCatCatalogRepository()
        repository.images = [makeImage(id: "1"), makeImage(id: "2")]

        let viewModel = CatListViewModel(repository: repository)
        viewModel.loadCatsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.catImages.count, 2)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadCatsIfNeededSetsErrorMessageOnFailure() async throws {
        let repository = FakeCatCatalogRepository()
        repository.error = NetworkError.requestFailed(500)

        let viewModel = CatListViewModel(repository: repository)
        viewModel.loadCatsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(viewModel.catImages.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadCatsIfNeededDoesNotReloadWhenAlreadyPopulated() async throws {
        let repository = FakeCatCatalogRepository()
        repository.images = [makeImage(id: "1")]

        let viewModel = CatListViewModel(repository: repository)
        viewModel.loadCatsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        repository.images = []
        viewModel.loadCatsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.catImages.count, 1)
    }

    func testReloadFetchesAgainEvenWhenAlreadyPopulated() async throws {
        let repository = FakeCatCatalogRepository()
        repository.images = [makeImage(id: "1")]

        let viewModel = CatListViewModel(repository: repository)
        viewModel.loadCatsIfNeeded()
        try await Task.sleep(nanoseconds: 200_000_000)

        repository.images = [makeImage(id: "1"), makeImage(id: "2"), makeImage(id: "3")]
        viewModel.reload()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.catImages.count, 3)
    }
}
