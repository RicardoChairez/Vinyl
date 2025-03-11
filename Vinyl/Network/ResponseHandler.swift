//
//  ResponseHandler.swift
//  Deserts
//
//  Created by Chip Chairez on 2/17/25.
//

import Foundation

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
    
}
