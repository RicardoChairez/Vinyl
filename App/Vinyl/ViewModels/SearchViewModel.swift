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
        case foundResults, searching, noResults
    }
    
    @Published var searchResult: [MediaPreview] = []
    @Published var searchText = ""
    @Published var isShowingScanner = false
    @Published var vmState: vmState = .foundResults
    
    @Published var isShowingFilterSheet = false
    @Published var selectedFormat: Format?
    @Published var selectedYear: Int?
    @Published var selectedCountry: String?
    
    func fetchSearchResult() async throws -> [MediaPreview]{
//        let endpoint = getEndpoint(query: searchText)
        
        let url = getURL(query: searchText)
        let mediaSearchResponse = try await NetworkManager.shared.request(modelType: MediaSearchResponse.self, url: url)
        return mediaSearchResponse.results
    }
    
    func getURL(query: String) -> URL? {
        var endpoint = "https://api.discogs.com/database/search?"
        endpoint.append("q=\(query)")
        endpoint.append("&type=release")
        if let format = selectedFormat {
            endpoint.append("&format=\(format.rawValue)")
        }
        if let year = selectedYear {
            endpoint.append("&year=\(year)")
        }
        if let country = selectedCountry {
            endpoint.append("&country=\(country)&country=\(Locale.current.localizedString(forRegionCode: country) ?? country)")
        }
        endpoint.append("&key=\(Constants.api.key)")
        endpoint.append("&secret=\(Constants.api.secret)")
        return URL(string: endpoint)
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
