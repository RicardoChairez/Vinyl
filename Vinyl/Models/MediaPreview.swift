//
//  Vinyl.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import Foundation

struct MediaPreview: Codable, Identifiable, Hashable {
    
    static func == (lhs: MediaPreview, rhs: MediaPreview) -> Bool {
        lhs.id == rhs.id &&
        lhs.resource_url == rhs.resource_url &&
        lhs.thumbImageData == rhs.thumbImageData
    }
//    enum CodingKeys: String, CodingKey {
//        case country = "country"
//        case year = "year"
//        case formats = "format"
//        case label = "label"
//        case genres = "genre"
//        case style = "style"
//        case mediaID = "id"
//        case masterId = "master_id"
//        case masterUrl = "master_url"
//        case releaseEndpoint = "resource_url"
//        case catno = "catno"
//        case title = "title"
//        case thumb = "thumb"
//        case coverImage = "cover_image"
//    }
    
    var id: Int
    var country: String?
    var year: String?
    var format: [String]
    var formatSet: Set<String> {
        Set(format)
    }
    var label: [String]
    var genre: [String]
    var style: [String]
//    var mediaID: Int
    var master_id: Int?
    var master_url: String?
    var resource_url: String?
    var catno: String
    var title: String
    var thumb: String
    var cover_image: String
    var thumbImageURL: URL? {
        URL(string: thumb)
    }
//    var coverImageURL: URL? {
//        URL(string: cover_image)
//    }
    var thumbImageData: Data?
//    var coverImageData: Data?
//    var estimatedPrice: String?
    
}

struct MediaSearchResponse: Codable {
    var results: [MediaPreview]
}

