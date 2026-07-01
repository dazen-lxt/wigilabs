//
//  VoteStore.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation
import SwiftData

protocol VoteStoring {
    func save(breedId: String, breedName: String, imageId: String, voteType: VoteType) throws
    func fetchAll() throws -> [VoteRecord]
}

nonisolated final class VoteStore: VoteStoring {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(breedId: String, breedName: String, imageId: String, voteType: VoteType) throws {
        let record = VoteRecord(breedId: breedId, breedName: breedName, imageId: imageId, voteType: voteType)
        context.insert(record)
        try context.save()
    }

    func fetchAll() throws -> [VoteRecord] {
        let descriptor = FetchDescriptor<VoteRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }
}
