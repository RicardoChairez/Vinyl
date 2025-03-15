//
//  ResponseHandler.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation
import SwiftSoup

class ResponseHandler {
    
    func parseResponseDecode<T: Decodable>(data: Data, modelType: T.Type, completion: ResultHandler<T>) {
        
        do {
            let userResponse = try JSONDecoder().decode(modelType, from: data)
            completion(.success(userResponse))
        }
        catch {
            completion(.failure(.decoding(error)))
        }
    }
    
    func parseHTMLForPrice(data: Data, completion: (Result<Double, NetworkError>) -> Void) {
        if let html = String(data: data, encoding: .utf8) {
            do {
                let document = try SwiftSoup.parse(html)
                let pricesElements = try document.getElementsByClass("s-item__price")
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                let prices: [Double] = try pricesElements.compactMap({formatter.number(from: try $0.text())?.doubleValue})
                if prices.isEmpty {
                    completion(.failure(.invalidData))
                    return
                }
                let average: Double = Double(prices.reduce(0, +) / Double(prices.count))
                completion(.success(average))
                
            }
            catch {
                completion(.failure(.parsing(error)))
            }
        }
        else {
            completion(.failure((.invalidData)))
        }
    }
}
