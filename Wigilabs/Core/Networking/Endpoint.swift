//
//  Endpoint.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    static func breeds() -> Endpoint {
        Endpoint(path: "/breeds")
    }

    static func image(id: String) -> Endpoint {
        Endpoint(path: "/images/\(id)")
    }

    static func imagesSearch(limit: Int, hasBreeds: Bool) -> Endpoint {
        Endpoint(path: "/images/search", queryItems: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "has_breeds", value: hasBreeds ? "1" : "0"),
        ])
    }
}
