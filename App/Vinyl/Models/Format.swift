//
//  Format.swift
//  Vinyl
//
//  Created by Chip Chairez on 5/3/25.
//

import Foundation

enum Format: String, CaseIterable, Identifiable {
    case vinyl = "Vinyl"
    case cd = "CD"
    case cassette = "Cassette"
    case file = "File"
    
    var id: String { self.rawValue }
}
