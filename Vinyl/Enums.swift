//
//  Enums.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/8/25.
//

import Foundation
import SwiftUICore

enum CollectionType {
    case owned, unowned
}

enum Sort: String, Equatable, CaseIterable {
    case addedRecent = "Added (Recent)"
    case addedOldest = "Added (Oldest)"
    case valueHigh = "Value (Highest)"
    case valueLow = "Value (Lowest)"
    case title = "Title"
    case artist = "Artist"
    case year = "Year"
    case label = "Label"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CustomError: Error {
    case notInCollection
}

enum Ownership: String, Codable {
    case owned = "COLLECTED"
    case unowned = "UNOWNED"
    case wanted = "WANTED"
}
