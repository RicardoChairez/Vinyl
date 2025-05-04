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
                    HStack {
                        Button {
                            vm.isShowingScanner = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .scaledToFit()
                        }
                        Button {
                            vm.isShowingFilterSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
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
            .sheet(isPresented: $vm.isShowingFilterSheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("Format")) {
                            Picker("Format", selection: $vm.selectedFormat) {
                                Text("Any").tag(Optional<Format>.none)
                                ForEach(Format.allCases) { format in
                                    Text(format.rawValue).tag(Optional(format))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Year")) {
                            Picker("Year", selection: $vm.selectedYear) {
                                Text("Any").tag(Optional<Int>.none)
                                ForEach((1900...2025).reversed(), id: \.self) { year in
                                    Text(String(year)).tag(Optional(year))
                                }
                            }
                        }
                        
                        Section(header: Text("Country")) {
                            Picker("Country", selection: $vm.selectedCountry) {
                                Text("Any").tag(Optional<String>.none)
                                ForEach(NSLocale.isoCountryCodes, id: \.self) { code in
                                    let name = Locale.current.localizedString(forRegionCode: code) ?? code
                                    Text(name).tag(Optional(code))
                                }
                            }
                        }
                    }
//                    .navigationTitle("Filters")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                vm.isShowingFilterSheet = false
                            }
                        }
                    }
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
