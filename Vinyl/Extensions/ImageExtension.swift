//
//  Image.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/1/25.
//

import Foundation
import SwiftUI

extension Image {
    init(data: Data) {
        if let uiImage = UIImage(data: data) {
            self = Image(uiImage: uiImage)
        }
        else {
            self = Image("")
        }
    }
}
