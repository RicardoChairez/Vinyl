//
//  Collections.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/28/25.
//

import Foundation
import SwiftData

@Model
final class Collections {
    init(ownedCollection: [MediaPreview], wantedCollection: [MediaPreview]) {
        self.ownedCollection = ownedCollection
        self.wantedCollection = wantedCollection
    }
    
    @Attribute(.externalStorage) var ownedCollection: [MediaPreview]
    @Attribute(.externalStorage) var wantedCollection: [MediaPreview]
    
}
