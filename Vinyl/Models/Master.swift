//
//  Master.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

//import Foundation
//
//struct Master: Codable, Identifiable, Hashable{
//    static func == (lhs: Master, rhs: Master) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    var id: Int
//    var genres: [String]
//    var styles: [String]
//    var year: Int
//    var tracklist: [Track]
//    var artists: [Artist]
//    var title: String
//    
//    var artist: String? {
//        if !artists.isEmpty {
//            return artists[0].name
//        }
//        return nil
//    }
//}
//
//struct Track: Codable, Hashable {
//    var position: String
//    var title: String
//    var duration: String
//}
//
//struct Artist: Codable, Hashable {
//    var name: String
//}
