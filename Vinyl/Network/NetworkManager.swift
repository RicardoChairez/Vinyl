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
        url: URL?,
        headers: [String: String]?,
        completion: @escaping ResultHandler<T>
    ) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        networkHandler.requestDataAPI(urlRequest: urlRequest) { result in
            switch result {
            case .success(let data):
                self.responseHandler.parseResponseDecode(data: data, modelType: modelType) { response in
                    switch response {
                    case .success(let mainResponse):
                        completion(.success(mainResponse))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchData(url: URL?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }
        let urlRequest = URLRequest(url: url)
        networkHandler.requestDataAPI(urlRequest: urlRequest) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAveragePrice(query: String, completion: @escaping (Result<Double, NetworkError>) -> Void) {
        let endpoint = URL(string: "https://www.ebay.com/sch/11233/i.html?_nkw=\(query)&_from=R40&LH_Sold=1&LH_Complete=1")
        fetchData(url: endpoint) { result in
            switch result {
            case .success(let data):
                self.responseHandler.parseHTMLForPrice(data: data) { result in
                    switch result {
                    case .success(let price):
                        completion(.success(price))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

enum NetworkError: Error {
    case invalidResponse
    case invalidURL
    case invalidData
    case network(Error?)
    case decoding(Error?)
    case parsing(Error?)
    case serverError
    case connnection
}
