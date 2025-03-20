//
//  NetworkHandler.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation

class RequestHandler {
    
    func requestDataAPI(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            //                    throw NetworkingError.invalidStatusCode(statusCode: -1)
            throw NetworkError.invalidResponse
        }
        guard let response = response as? HTTPURLResponse,
              200 ... 299 ~= statusCode else {
            throw NetworkError.invalidResponse
        }
        switch statusCode {
        case 400 ..< 500: throw NetworkError.network
        case 500 ..< 600: throw NetworkError.serverError
        default:
            break
        }
        
        return data
    }
}
