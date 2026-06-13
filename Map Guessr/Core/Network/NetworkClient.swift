//
//  NetworkClient.swift
//  Map Guessr
//
//  Created by Abir Pal on 07/04/2026.
//

import Foundation

class NetworkClient {
    
    // For JSON Responses (e.g., getCountryNames, getClue)
    static func request<T: Decodable>(_ request: URLRequest, session: URLSession = .shared) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // For Empty Responses or Status-Only Checks (e.g., evaluateResult)
    @discardableResult
    static func requestStatus(_ request: URLRequest, session: URLSession = .shared) async throws -> Bool {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return true
    }
    
    // For Raw Data Responses (e.g., getCountryOutline)
    static func requestData(_ request: URLRequest, session: URLSession = .shared) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return data
    }
    
    // Extract custom Python errors
    private static func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(message: "Invalid server response.")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let serverErrorObj = try? JSONDecoder().decode([String: String].self, from: data),
               let detailMessage = serverErrorObj["detail"] {
                throw NetworkError.serverError(message: detailMessage)
            } else if let fallbackErrorString = String(data: data, encoding: .utf8), !fallbackErrorString.isEmpty {
                throw NetworkError.serverError(message: fallbackErrorString)
            } else {
                throw NetworkError.serverError(message: "HTTP Error \(httpResponse.statusCode)")
            }
        }
    }
}


enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The server URL is invalid."
        case .serverError(let message): return message
        }
    }
}
