//
//  APIManager.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation
import SwiftSoup

typealias ResultHandler<T> = (Result<T, NetworkError>) -> Void

final class NetworkManager {
    static let shared = NetworkManager()
    private let networkHandler: RequestHandler
    private let responseHandler: ResponseHandler
    
    private init(networkHandler: RequestHandler = RequestHandler(),
             responseHandler: ResponseHandler = ResponseHandler()) {
        self.networkHandler = networkHandler
        self.responseHandler = responseHandler
    }
    
    func request<T: Codable>(
        modelType: T.Type,
        url: URL?) async throws(Error) -> T {
            let data = try await fetchData(url: url)
            let mainResponse = try await responseHandler.parseResponseDecode(data: data, modelType: modelType)
            return mainResponse
        }
    
    func fetchData(url: URL?) async throws(Error) -> Data {
        guard let url = url else {
            throw NetworkError.invalidURL
        }
        let data = try await networkHandler.requestDataAPI(url: url)
        return data
    }
    
    func getAveragePrice(query: String) async throws(Error) -> Double {
        let url = URL(string: "https://www.ebay.com/sch/11233/i.html?_nkw=\(query)&_from=R40&LH_Sold=1&LH_Complete=1")
        let data = try await fetchData(url: url)
        let averagePrice = try await responseHandler.parseHTMLForPrice(data: data)
        return averagePrice
    }

}

enum NetworkError: Error {
    case invalidResponse
    case invalidURL
    case invalidData
    case network
    case statusCode
    case decoding(Error?)
    case parsing(Error?)
    case serverError
    case connnection
}
