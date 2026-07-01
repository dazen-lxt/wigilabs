//
//  VotingCard.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 01/07/26.
//

import Foundation

struct VotingCard: Identifiable {
    let id = UUID()
    let breed: Breed
    let image: CatImage
}
