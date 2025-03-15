//
//  Media.swift
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
        self.dateAdded = Date.randomBetween(start: Calendar.current.date(byAdding: .year, value: -10, to: Date())!, end: Date.now)
        self.ownership = .unowned
        self.notes = ""
        self.customValueFlag = false
    }
    
    var dateAdded: Date
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: dateAdded)
    }
    var mediaPreview: MediaPreview
    var release: Release?
    var customValueFlag: Bool
    var value: Double?
    var ownership: Ownership
    var folder: String?
    var notes: String
    @Attribute(.externalStorage) var coverImageData: Data?
}
