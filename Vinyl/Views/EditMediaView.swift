//
//  EditMediaView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/13/25.
//

import SwiftUI

struct EditMediaView: View {
    @Binding var media: Media
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(media.release?.title ?? "")")
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done"){}
                }
            })
            .navigationTitle("Edit Album")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    EditMediaView()
//}
