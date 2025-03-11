//
//  StringExtension.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/1/25.
//

import Foundation

extension String {
    static func getStringArrayString(_ arr: [String]) -> String {
        var out = ""
        if arr.count > 0 {
            for item in arr {
                out = out + item + ", "
            }
            out = String(out.dropLast(2))
        }
        return out
    }
}
