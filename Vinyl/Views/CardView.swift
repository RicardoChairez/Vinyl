//
//  CardView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/15/25.
//

import SwiftUI

struct CardView<Content: View>: View {
    init(color: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.color = color ?? .offPrimary
        self.content = content
    }
    
    var color: Color?
    var content: () -> Content
    
    var body: some View {
        VStack {
            Group(content: content)
                .padding()
        }
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

//#Preview {
//    CardView()
//}
