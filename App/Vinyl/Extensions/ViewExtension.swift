//
//  ViewExtension.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/14/25.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
