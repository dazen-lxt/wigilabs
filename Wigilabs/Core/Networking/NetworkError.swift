//
//  NetworkError.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed(Error)
    case missingData
    case unknown(Error)
}
