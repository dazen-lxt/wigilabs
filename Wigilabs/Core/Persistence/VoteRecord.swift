//
//  VoteRecord.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation
import SwiftData

@Model
final class VoteRecord {
    var id: UUID
    var breedId: String
    var breedName: String
    var imageId: String
    var voteTypeRaw: Int
    var date: Date

    var voteType: VoteType {
        get { VoteType(rawValue: voteTypeRaw) ?? .like }
        set { voteTypeRaw = newValue.rawValue }
    }

    init(breedId: String, breedName: String, imageId: String, voteType: VoteType, date: Date = .now) {
        self.id = UUID()
        self.breedId = breedId
        self.breedName = breedName
        self.imageId = imageId
        self.voteTypeRaw = voteType.rawValue
        self.date = date
    }
}
