//
//  APIClient.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class URLSessionAPIClient: APIClientProtocol {
    private let session: URLSession
    private let baseURL: URL
    private let apiKey: String?
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, baseURL: URL = AppConfig.baseURL, apiKey: String? = AppConfig.apiKey) {
        self.session = session
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await execute(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    private func execute(_ endpoint: Endpoint) async throws -> Data {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.requestFailed(httpResponse.statusCode)
            }
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
