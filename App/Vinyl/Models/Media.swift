//
//  Media.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/28/25.
//

import Foundation
import SwiftData

@Model
final class Media: ObservableObject {
//    init(mediaPreview: MediaPreview, coverImageData: Data?, ownership: Ownership) {
//        self.mediaPreview = mediaPreview
//        self.coverImageData = coverImageData
//        self.dateAdded = .now
//        self.ownership = ownership
//    }
    
    init(mediaPreview: MediaPreview) {
        self.mediaPreview = mediaPreview
        self.coverImageData = nil
    }
    
    var dateAdded: Date = Date.now
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: dateAdded)
    }
    var mediaPreview: MediaPreview = MediaPreview()
    var release: Release?
    var customValueFlag: Bool = false
    var value: Double?
    var ownership: Ownership = Ownership.unowned
    var folder: String?
    var notes: String = ""
    @Attribute(.externalStorage) var coverImageData: Data?
}
