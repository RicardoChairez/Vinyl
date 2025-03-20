//
//  Release.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/1/25.
//

import Foundation

// MARK: - Release
struct Release: Codable, Identifiable, Hashable {
    static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
    }
    
//    enum CodingKeys: String, CodingKey {
//        case id, status, year
////        case resourceURL = "resource_url"
////        case uri
//        case artists_sort
////        case dataQuality = "data_quality"
////        case formatQuantity = "format_quantity"
////        case dateAdded = "date_added"
////        case dateChanged = "date_changed"
////        case numForSale = "num_for_sale"
////        case lowestPrice = "lowest_price"
////        case masterID = "master_id"
////        case masterURL = "master_url"
////        case title, country, released, notes
////        case releasedFormatted = "released_formatted"
////        case thumb
////        case estimatedWeight = "estimated_weight"
////        case blockedFromSale = "blocked_from_sale"
//    }
    
    
    var id: Int
    var status: String?
    var year: Int?
//    let resourceURL, uri: String?
    var artists: [Artist]
//    private let artists_sort: String?
    let labels: [Company]
    var label: String? { if !labels.isEmpty{ return labels[0].name} else { return nil }}
////    let companies: [Company]
////    let formats: [Format]
//    let dataQuality: String?
//    let formatQuantity: Int?
//    let dateAdded, dateChanged: String?
//    let numForSale: Int?
//    let lowestPrice: Double?
//    let masterID: Int?
//    let masterURL: String?
    var title: String
    let country, notes: String?
    let released_formatted: String?
//    let releasedFormatted: String?
////    let identifiers: [Identifier]
////    let videos: [Video]
////    let genres, styles: [String]
    let tracklist: [Track]?
////    let extraartists: [Artist]
////    let images: [Img]
//    let thumb: String?
//    let estimatedWeight: Int?
//    let blockedFromSale: Bool?
//

//}
//
//// MARK: - Artist
struct Artist: Codable, Hashable {
    let name, anv, join, role: String?
    let tracks: String?
    let id: Int?
    let resourceURL: String?
    let thumbnailURL: String?
}
//
//
//// MARK: - Rating
//struct Rating: Codable {
//    let count: Int?
//    let average: Double?
//}
//
//// MARK: - Company
struct Company: Codable, Hashable {
    let name, catno, entityType, entityTypeName: String?
    let id: Int?
    let resourceURL: String?
    let thumbnailURL: String?
}
//
//// MARK: - Format
//struct Format: Codable, Hashable {
//    static func == (lhs: Format, rhs: Format) -> Bool {
//        lhs.name == rhs.name && lhs.qty == rhs.qty
//    }
//    let name, qty: String?
////    let descriptions: [String]?
//}
//
//// MARK: - Identifier
//struct Identifier: Codable, Hashable {
//    static func == (lhs: Identifier, rhs: Identifier) -> Bool {
//        lhs.description == rhs.description && lhs.value == rhs.value
//    }
//    let value, description: String?
//}
//
//
//// MARK: - Image
//struct Img: Codable, Hashable {
//    static func == (lhs: Img, rhs: Img) -> Bool {
//        lhs.uri == rhs.uri
//    }
//    
//    let uri, resourceURL, uri150: String?
//    let width, height: Int?
//}
//
//
//// MARK: - Tracklist
struct Track: Codable, Hashable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.position == rhs.position && lhs.title == rhs.title && lhs.duration == rhs.duration
    }
    let position: String?
    let title: String?
//    let extraartists: [Artist]
    let duration: String?
}
//
//
//// MARK: - Video
//struct Video: Codable, Hashable {
//    static func == (lhs: Video, rhs: Video) -> Bool {
//        lhs.uri == rhs.uri
//    }
//    let uri: String?
//    let title, description: String?
//    let duration: Int?
//    let embed: Bool?
}

