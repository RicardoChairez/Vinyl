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
    case added = "Added"
    case title = "Title"
    case artist = "Artist"
    case year = "Year"
    case label = "Label"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
