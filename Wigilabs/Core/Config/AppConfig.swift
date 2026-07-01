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
        guard let key = Bundle.main.object(forInfoDictionaryKey: "CAT_API_KEY") as? String else {
            return nil
        }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
