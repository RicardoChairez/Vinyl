//
//  MediaModel.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/28/25.
//

import Foundation
import SwiftData

@Model
class Media {
    init(mediaPreview: MediaPreview, coverImageData: Data?, isInCollection: Bool) {
        self.mediaPreview = mediaPreview
        self.coverImageData = coverImageData
        self.dateAdded = .now
        self.isInCollection = isInCollection
    }
    
    var dateAdded: Date
    var mediaPreview: MediaPreview
    var release: Release?
    var estimatedPrice: Double?
    var isInCollection: Bool
    @Attribute(.externalStorage) var coverImageData: Data?
    
}
