//
//  SearchView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import CodeScanner
import SwiftUI
import AVFoundation

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
                            ForEach($vm.medias) { $mediaPreview in
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
                MediaView(vm: MediaViewModel(mediaPreview: mediaPreview, coverImageData: nil, isInCollection: false))
            }
            .navigationTitle("Search")
            .searchable(text: $vm.searchText)
            .onSubmit(of: .search){
                Task {
                    await vm.search(query: vm.searchText) { error in
                        if let error = error {
                            vm.showErrorDrop(error: error)
                        }
                    }
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
                        vm.handleScan(result: result)
                    }
                    .aspectRatio(1.5, contentMode: .fit)
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
