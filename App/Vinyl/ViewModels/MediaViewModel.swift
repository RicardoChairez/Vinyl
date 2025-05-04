//
//  MediaViewModel.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import Foundation

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
    @Published var viewDidLoad = false
    @Published var editIsPresented = false
    @Published var removeIsConfirming = false
    
    
    func fetchRelease() async throws -> Release {
        if let release = media.release { return release }
        let endpoint = media.mediaPreview.resource_url ?? ""
        let url = URL(string: endpoint)
        let release = try await NetworkManager.shared.request(modelType: Release.self, url: url)
        return release
    }
    
    func fetchOtherVersions() async -> [MediaPreview]{
        guard let query = media.mediaPreview.title, otherVersions.isEmpty else { return otherVersions }
        let endpoint = getEndpoint(query: query)
        let url = URL(string: endpoint)
        let mediaSearchResponse = try? await NetworkManager.shared.request(modelType: MediaSearchResponse.self, url: url)
        let otherVersions = mediaSearchResponse?.results.filter({
            $0.master_id == self.media.mediaPreview.master_id &&
            $0.id != self.media.mediaPreview.id
        })
        return otherVersions ?? []
    }
    
    func getEndpoint(query: String) -> String{
        return "https://api.discogs.com/database/search?q=\(query)&type=release&per_page=20&key=\(Constants.api.key)&secret=\(Constants.api.secret)"
    }
    
    func getOtherVersionsImageData() async {
        for mediaPreview in otherVersions {
            if let index = otherVersions.firstIndex(where: {$0 == mediaPreview}), otherVersions[index].thumbImageData == nil, mediaPreview.thumbImageURL != nil {
                otherVersions[index].thumbImageData = await fetchThumbImage(mediaPreview)
            }
        }
    }
    
    func fetchThumbImage(_ mediaPreview: MediaPreview) async -> Data?{
        let data = try? await NetworkManager.shared.fetchData(url: mediaPreview.thumbImageURL)
        return data
    }
    
    func fetchCoverImageData() async -> Data?{
        if let data = media.coverImageData { return data }
        guard let coverImage = media.mediaPreview.cover_image, coverImage.contains(".jpeg") else {
            return nil
        }
        let url = URL(string: coverImage)
        let data = try? await NetworkManager.shared.fetchData(url: url)
        return data
    }
    
    func toggleDescription() {
        if descriptionLines == nil {
            descriptionLines = 3
        }
        else {
            descriptionLines = nil
        }
    }
    
    func getEstimatedPrice() async -> Double?{
        if media.customValueFlag { return media.value }
        let query: String
        if let catno = media.mediaPreview.catno, !catno.isEmpty {
            query = catno
        }
        else {
            query = "\(media.mediaPreview.title ?? "") \((media.mediaPreview.year ?? ""))"
        }
        do {
            let value = try await NetworkManager.shared.getAveragePrice(query: query)
            return value
        }
        catch {
            return media.value
        }
    }
}

