//
//  VoteStoreTests.swift
//  WigilabsTests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import XCTest
import SwiftData
@testable import Wigilabs

@MainActor
final class VoteStoreTests: XCTestCase {
    private func makeInMemoryStore() throws -> VoteStore {
        let schema = Schema([VoteRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return VoteStore(context: ModelContext(container))
    }

    func testSaveAndFetchAllReturnsSavedVote() throws {
        let store = try makeInMemoryStore()

        try store.save(breedId: "abys", breedName: "Abyssinian", imageId: "img1", voteType: .like)

        let votes = try store.fetchAll()
        XCTAssertEqual(votes.count, 1)
        XCTAssertEqual(votes.first?.breedId, "abys")
        XCTAssertEqual(votes.first?.breedName, "Abyssinian")
        XCTAssertEqual(votes.first?.imageId, "img1")
        XCTAssertEqual(votes.first?.voteType, .like)
    }

    func testFetchAllReturnsMostRecentVoteFirst() throws {
        let store = try makeInMemoryStore()

        try store.save(breedId: "a", breedName: "A", imageId: "img-a", voteType: .like)
        try store.save(breedId: "b", breedName: "B", imageId: "img-b", voteType: .dislike)

        let votes = try store.fetchAll()
        XCTAssertEqual(votes.count, 2)
        XCTAssertEqual(votes.first?.breedId, "b")
        XCTAssertEqual(votes.last?.breedId, "a")
    }

    func testFetchAllOnEmptyStoreReturnsEmptyArray() throws {
        let store = try makeInMemoryStore()

        let votes = try store.fetchAll()
        XCTAssertTrue(votes.isEmpty)
    }
}
