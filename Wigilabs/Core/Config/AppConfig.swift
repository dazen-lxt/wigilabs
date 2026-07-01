//
//  AppConfig.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

enum AppConfig {
    static let baseURL = URL(string: "https://api.thecatapi.com/v1")!

    static var apiKey: String? {
        let trimmed = GeneratedSecrets.catAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
