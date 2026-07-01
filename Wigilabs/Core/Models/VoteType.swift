//
//  VoteType.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

enum VoteType: Int, Codable, CaseIterable {
    case dislike = 0
    case like = 1

    var label: String {
        switch self {
        case .like: return String(localized: "voting.like", defaultValue: "Me gusta")
        case .dislike: return String(localized: "voting.dislike", defaultValue: "No me gusta")
        }
    }
}
