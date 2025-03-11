//
//  NetworkHandler.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation

class RequestHandler {
    
    func requestDataAPI(urlRequest: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let session = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  200 ... 299 ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            switch response.statusCode {
            case 400 ..< 500: completion(.failure(.network(error)))
            case 500 ..< 600: completion(.failure(.serverError))
            default:
                break
            }
            
            guard let data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(data))
        }
        session.resume()
    }
}
