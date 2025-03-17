//
//  ResponseHandler.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation
import SwiftSoup

class ResponseHandler {
    
    func parseResponseDecode<T: Decodable>(data: Data, modelType: T.Type) async throws(Error) -> T {
        
        do {
            let userResponse = try JSONDecoder().decode(modelType, from: data)
            return userResponse
        }
        catch {
            throw NetworkError.decoding(error)
        }
    }
    
    func parseHTMLForPrice(data: Data) async throws(Error) -> Double {
        if let html = String(data: data, encoding: .utf8) {
            do {
                let document = try SwiftSoup.parse(html)
                let pricesElements = try document.getElementsByClass("s-item__price")
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                let prices: [Double] = try pricesElements.compactMap({formatter.number(from: try $0.text())?.doubleValue})
                if prices.isEmpty {
                    throw NetworkError.invalidData
                }
                let average: Double = Double(prices.reduce(0, +) / Double(prices.count))
                return average
                
            }
            catch {
                throw NetworkError.parsing(error)
            }
        }
        else {
            throw NetworkError.invalidData
        }
    }
}
