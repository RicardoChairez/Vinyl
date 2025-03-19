//
//  SearchViewModel.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import Foundation
import SwiftData

@MainActor
class SearchViewModel: ObservableObject {
    enum vmState {
        case notSearching, searching
    }
    
    @Published var searchResult: [MediaPreview] = []
    @Published var searchText = "to pimp a butterfly"
    @Published var isShowingScanner = false
    @Published var vmState: vmState = .notSearching
    
    func fetchSearchResult() async throws -> [MediaPreview]{
        let endpoint = getEndpoint(query: searchText)
        let url = URL(string: endpoint)
        let mediaSearchResponse = try await NetworkManager.shared.request(modelType: MediaSearchResponse.self, url: url)
        return mediaSearchResponse.results
    }
    
    func getEndpoint(query: String) -> String{
        return "https://api.discogs.com/database/search?q=\(query)&type=release&\(Constants.api.key)"
    }
    
    func downloadImages() async {
        for media in searchResult {
            await downloadImage(media)
        }
    }
    
    func downloadImage(_ media: MediaPreview) async {
        guard let index = searchResult.firstIndex(where: {$0 == media}), searchResult[index].thumbImageData == nil, media.thumbImageURL != nil else {
            return
        }
        let data = try? await NetworkManager.shared.fetchData(url: media.thumbImageURL)
        searchResult[index].thumbImageData = data
    }
    
    func setState(state: vmState) {
        self.vmState = state
    }
}
