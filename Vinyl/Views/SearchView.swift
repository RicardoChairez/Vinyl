//
//  SearchView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.


import CodeScanner
import SwiftUI
import AVFoundation
import Drops

struct SearchView: View {
    
    @StateObject private var vm = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.vmState == .searching {
                    ProgressView()
                        .ignoresSafeArea(.keyboard)
                }
                else {
                    ScrollView {
                        VStack {
                            ForEach($vm.searchResult) { $mediaPreview in
                                NavigationLink(value: mediaPreview) {
                                    MediaPreviewView(mediaPreview: $mediaPreview)
                                }
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.leading)
            .padding(.vertical)
            .navigationDestination(for: MediaPreview.self) { mediaPreview in
                MediaView(vm: MediaViewModel(mediaPreview: mediaPreview))
            }
            .navigationTitle("Search")
            .searchable(text: $vm.searchText)
            .onSubmit(of: .search){
                Task {
                    await search()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.isShowingScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .scaledToFit()
                    }
                }
            }
            .sheet(isPresented: $vm.isShowingScanner) {
                
                VStack(spacing: 20){
                    VStack {
                        Text("Scan")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Position barcode in frame")
                            .foregroundStyle(.secondary)
                    }
                    CodeScannerView(codeTypes: [.upce, .ean8, .ean13, .code128, .code93, .code39, .pdf417], scanMode: .continuous, simulatedData: "7 2064-24425-2 4") { result in
                        handleScan(result: result)
                    }
                    .aspectRatio(1.5, contentMode: .fit)
                    .presentationDetents([.medium])
                }
            }
        }
    }
    
    func search() async {
        vm.setState(state: .searching)
        async let searchResult = vm.fetchSearchResult()
        
        do {
            let (fetchedSearchResult) = try await (searchResult)
            vm.searchResult = fetchedSearchResult
        }
        catch {
            showErrorDrop(error: error)
        }
        
        vm.setState(state: .notSearching)
        await vm.downloadImages()
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        vm.isShowingScanner = false
        switch result {
        case.success(let result):
            vm.searchText = result.string
            Task {
                await search()
            }
        case.failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func showErrorDrop(error: Error) {
        let drop = Drop(title: "Error", subtitle: error.localizedDescription, subtitleNumberOfLines: 2)
        Drops.show(drop)
    }
}

//#Preview {
//    SearchView()
//}
