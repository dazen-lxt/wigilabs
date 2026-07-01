//
//  Breed.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

struct Breed: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let temperament: String?
    let origin: String?
    let description: String?
    let referenceImageId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, temperament, origin, description
        case referenceImageId = "reference_image_id"
    }
}
