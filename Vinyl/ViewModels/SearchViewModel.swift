//
//  SearchViewModel.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import CodeScanner
import Foundation
import Drops
import SwiftData
import SwiftUICore

@MainActor
class SearchViewModel: ObservableObject {
    enum vmState {
        case notSearching, searching
    }
    
    @Published var medias: [MediaPreview] = []
    var searchText = "to pimp a butterfly"
    @Published var isShowingScanner = false
    @Published var vmState: vmState = .notSearching
    
    func search(query: String, completion: @escaping (NetworkError?) -> ()) async {
        setState(state: .searching)
        let endpoint = getEndpoint(query: query)
        let url = URL(string: endpoint)
        NetworkManager.shared.request(modelType: MediaSearchResponse.self, url: url, headers: nil){ result in
            Task {
                await MainActor.run {
                    self.setState(state: .notSearching)
                }
            }
            switch result {
            case .success(let response):
                Task {
                    await MainActor.run {
                        self.medias = response.results
                    }
                    await self.downloadImages()
                }
                completion(nil)
            case .failure(let error):
                print(error)
                completion(error)
            }
        }
    }
    
    func getEndpoint(query: String) -> String{
        return "https://api.discogs.com/database/search?q=\(query)&type=release&\(Constants.api.key)"
    }
    
    func downloadImages() async {
        for media in medias {
            await downloadImage(media)
        }
    }
    
    func downloadImage(_ media: MediaPreview) async {
        guard let index = medias.firstIndex(where: {$0 == media}), medias[index].thumbImageData == nil, media.thumbImageURL != nil else {
            return
        }
        NetworkManager.shared.fetchData(url: media.thumbImageURL) { result in
            switch result {
            case .success(let imageData):
                Task {
                    await MainActor.run {
                        self.medias[index].thumbImageData = imageData
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        searchText = ""
        switch result {
        case.success(let result):
            let details = result.string
            Task {
                await search(query: details) { error in
                    if let error = error {
                        self.showErrorDrop(error: error)
                    }
                }
            }
        case.failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func showErrorDrop(error: Error) {
        let drop = Drop(title: "Error", subtitle: error.localizedDescription, subtitleNumberOfLines: 2)
        Drops.show(drop)
    }
    
    func setState(state: vmState) {
        self.vmState = state
    }
}
