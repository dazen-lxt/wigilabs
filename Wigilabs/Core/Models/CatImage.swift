//
//  CatImage.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

struct CatImage: Codable, Identifiable, Hashable {
    let id: String
    let url: String
    let width: Int?
    let height: Int?
    let breeds: [Breed]?
}
