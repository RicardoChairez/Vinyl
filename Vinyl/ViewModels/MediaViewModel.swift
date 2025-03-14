//
//  MediaViewModel.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import Foundation
import SwiftUI
import Drops

@MainActor
class MediaViewModel: ObservableObject {
    init(mediaPreview: MediaPreview) {
        self.media = Media(mediaPreview: mediaPreview)
    }
    
    init(media: Media) {
        self.media = media
    }
    
    @Published var media: Media
    @Published var otherVersions: [MediaPreview] = []
    @Published var descriptionLines: Int? = 3
    
    func getRelease() async {
        guard let endpoint = media.mediaPreview.resource_url else { return }
        let url = URL(string: endpoint)
        NetworkManager.shared.request(modelType: Release.self, url: url, headers: nil){ result in
            switch result {
            case .success(let release):
                self.media.release = release
                Task {
                    await self.getOtherVersions(query: "\(self.media.release!.title) \(self.media.release!.artists.first?.name ?? "")")
                }
            case .failure(let error):
                    (error)
                let drop = Drop(title: "Error", subtitle: error.localizedDescription, subtitleNumberOfLines: 2)
                Drops.show(drop)
//                completion(error)
            }
        }
    }
    
    func getOtherVersions(query: String) async {
        let endpoint = getEndpoint(query: query)
        let url = URL(string: endpoint)
        NetworkManager.shared.request(modelType: MediaSearchResponse.self, url: url, headers: nil){ result in
            switch result {
            case .success(let response):
                Task {
                    await MainActor.run {
                        self.otherVersions = response.results.filter({
                            $0.master_id == self.media.mediaPreview.master_id &&
                            $0.id != self.media.mediaPreview.id
                        })
                    }
                    await self.downloadOtherVersionImages()
                }
//                completion(nil)
            case .failure(let error):
                print(error)
//                completion(error)
            }
        }
    }
    
    func getEndpoint(query: String) -> String{
        return "https://api.discogs.com/database/search?q=\(query)&type=release&per_page=20&\(Constants.api.key)"
    }
    
    func downloadOtherVersionImages() async {
        for mediaPreview in otherVersions {
            await downloadMediaPreviewImage(mediaPreview)
        }
    }
    
    func downloadMediaPreviewImage(_ mediaPreview: MediaPreview) async {
        guard let index = otherVersions.firstIndex(where: {$0 == mediaPreview}), otherVersions[index].thumbImageData == nil, mediaPreview.thumbImageURL != nil else {
            return
        }
        NetworkManager.shared.fetchData(url: mediaPreview.thumbImageURL) { result in
            switch result {
            case .success(let imageData):
                Task {
                    await MainActor.run {
                        self.otherVersions[index].thumbImageData = imageData
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadImage() async {
        guard media.mediaPreview.cover_image.contains(".jpeg"), let coverImageURL = URL(string: media.mediaPreview.cover_image) else {
            return
        }
        NetworkManager.shared.fetchData(url: coverImageURL) { result in
            switch result {
            case .success(let imageData):
                Task {
                    await MainActor.run {
                        self.media.coverImageData = imageData
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func toggleDescription() {
        if descriptionLines == nil {
            descriptionLines = 3
        }
        else {
            descriptionLines = nil
        }
    }
    
    func getEstimatedPrice() async {
        let query: String
        if media.mediaPreview.catno.isEmpty {
            query = "\(media.mediaPreview.title) \((media.mediaPreview.year ?? ""))"
        }
        else {
            query = media.mediaPreview.catno
        }
        NetworkManager.shared.getAveragePrice(query: query) { result in
            switch result {
            case .success(let price):
                Task {
                    await MainActor.run {
                        self.media.value = price
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

