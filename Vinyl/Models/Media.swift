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
//    init(mediaPreview: MediaPreview, coverImageData: Data?, ownership: Ownership) {
//        self.mediaPreview = mediaPreview
//        self.coverImageData = coverImageData
//        self.dateAdded = .now
//        self.ownership = ownership
//    }
    
    init(mediaPreview: MediaPreview) {
        self.mediaPreview = mediaPreview
        self.coverImageData = nil
        self.dateAdded = .now
        self.ownership = .unowned
    }
    
    var dateAdded: Date
    var mediaPreview: MediaPreview
    var release: Release?
    var estimatedValue: Double?
    var ownership: Ownership
    var folder: String?
    @Attribute(.externalStorage) var coverImageData: Data?
}
