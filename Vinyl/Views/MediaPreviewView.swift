//
//  MediaPreviewView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/9/25.
//

import SwiftUI

struct MediaPreviewView: View {
    @Binding var mediaPreview: MediaPreview
    var body: some View {
        VStack {
            HStack(alignment: .center){
                VStack {
                    if let imageData = mediaPreview.thumbImageData {
                        Image(data: imageData)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                    }
                    else {
                        Color.secondary
                            .frame(width: 70, height: 70)
                    }
                    Text(mediaPreview.format.first ?? "")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    Text(mediaPreview.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text((mediaPreview.year ?? "????") + " " + (mediaPreview.label.first ?? ""))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
//                    Text(mediaPreview.genre.first ?? "")
//                        .font(.caption2)
//                        .lineLimit(1)
//                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            Divider()
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    MediaPreviewView()
//}
