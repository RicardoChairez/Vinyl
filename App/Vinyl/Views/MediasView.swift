//
//  CollectionView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import SwiftUI
import SwiftData
import Drops

struct MediasView: View {
    init(searchText: String = "", ownership: Ownership) {
        self.searchText = searchText
        self.ownership = ownership
        if ownership == .owned {
            self.title = "Collection"
        }
        else {
            self.title = "Wantlist"
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query var collection: [Media]
    @Namespace private var namespace
    
    @State var searchText = ""
    @State var accountIsPresented = false
    @State var sort: Sort = .addedRecent
    @State var albumCount: Int = 0
    @State var collectionValue: Double = 0.0
    
    @State var exportURL: URL?
    @State var showExporterSheet = false
    
    let ownership: Ownership
    let title: String
    var filteredCollection: [Media] { filterCollection() }
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10),
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredCollection) { media in
                        NavigationLink(value: media) {
                            VStack {
                                if let coverImageData = media.coverImageData {
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .aspectRatio(1, contentMode: .fill)
                                        .overlay {
                                            Image(data: coverImageData)
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(4)
                                                .shadow(color: Color.black.opacity(0.2), radius: 2)
                                        }
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(media.release?.title ?? media.mediaPreview.title ?? "" )
                                        Text(media.release?.artists.first?.name ?? "")
                                            .foregroundStyle(Color.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                }
                            }
                        }
                        .matchedTransitionSource(id: "zoom\(media.id)", in: namespace)
                        .contextMenu {
                            if ownership != .owned {
                                Button {
                                    withAnimation {
                                        addToCollection(media: media)
                                    }
                                } label: {
                                    HStack {
                                        Text("Add to Collection")
                                        Image(systemName: "plus")
                                    }
                                }
                            }
                            Button(role: .destructive) {
                                withAnimation {
                                    removeFromCollection(media: media)
                                }
                            } label: {
                                HStack {
                                    Text("Remove")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $accountIsPresented, content: {
                AccountView()
            })
            .searchable(text: $searchText, prompt: "Album, Format, Genre, Artist")
            .navigationDestination(for: Media.self) { media in
                MediaView(vm: MediaViewModel(media: media))
                    .navigationTransition(.zoom(sourceID: "zoom\(media.id)", in: namespace))
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button() {
                        accountIsPresented = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Menu {
                            Picker(selection: $sort) {
                                ForEach(Sort.allCases, id: \.self) { sort in
                                    Text(sort.localizedName)
                                        .tag(sort)
                                }
                            } label: {
                                
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        
                        Menu {
                            ShareLink(item:generateCSV()) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                }
            }
        }
    }
    
    func removeFromCollection(media: Media) {
        do {
            modelContext.delete(media)
            try modelContext.save()
            media.ownership = .unowned
            let drop = Drop(title: "Successfully removed", icon: UIImage(systemName: "checkmark"))
            Drops.show(drop)
        }
        catch {
            print(error.localizedDescription)
            let drop = Drop(title: "Failed to remove", titleNumberOfLines: 1, subtitle: error.localizedDescription, subtitleNumberOfLines: 2, icon: UIImage(systemName: "xmark"))
            Drops.show(drop)
        }
    }
    
    func addToCollection(media: Media) {
        do {
            media.dateAdded = .now
            media.ownership = .owned
            modelContext.insert(media)
            try modelContext.save()
            let drop = Drop(title: "Successfully added", titleNumberOfLines: 1, subtitle: nil, subtitleNumberOfLines: 0, icon: UIImage(systemName: "checkmark"))
            Drops.show(drop)
        }
        catch {
            print(error.localizedDescription)
            let drop = Drop(title: Constants.drop.addToCollectionFailure, titleNumberOfLines: 1, subtitle: error.localizedDescription, subtitleNumberOfLines: 2, icon: UIImage(systemName: "xmark"))
            Drops.show(drop)
        }
    }
    
    func sortCollection(collection: [Media]) -> [Media] {
        switch sort {
        case .label:
            return collection.sorted(by: {($0.release?.labels.first?.name ?? "") < ($1.release?.labels.first?.name ?? "")})
        case .artist:
            return collection.sorted(by: {($0.release?.artists.first?.name ?? "") < ($1.release?.artists.first?.name ?? "")})
        case .title:
            return collection.sorted(by: {$0.release?.title ?? "" < $1.release?.title ?? ""})
        case .addedRecent:
            return collection.sorted(by: {$0.dateAdded > $1.dateAdded})
        case .addedOldest:
            return collection.sorted(by: {$0.dateAdded < $1.dateAdded})
        case .year:
            return collection.sorted(by: {$0.mediaPreview.year ?? "" < $1.mediaPreview.year ?? ""})
        case .valueHigh:
            return collection.sorted(by: {$0.value ?? -2.0 > $1.value ?? -1.0})
        case .valueLow:
            return collection.sorted(by: {$0.value ?? -1.0 < $1.value ?? -2.0})
        }
    }
    
    func filterCollection() -> [Media]{
        var filteredCollection = collection.filter({$0.ownership == self.ownership})
        filteredCollection = sortCollection(collection: filteredCollection)
        if searchText.isEmpty {
            return filteredCollection
        }
        else {
            let lowercasedSearchText = searchText.lowercased()
            filteredCollection = filteredCollection.filter { media in
                (media.release?.title?.lowercased() ?? "").contains(lowercasedSearchText) ||
                (media.release?.artists ?? []).contains(where: {$0.name?.lowercased().contains(lowercasedSearchText) ?? false}) ||
                media.mediaPreview.genre.contains(where: {$0.lowercased().contains(lowercasedSearchText)}) ||
                media.mediaPreview.format.contains(where: {$0.lowercased().contains(lowercasedSearchText)})
            }
        }
        return filteredCollection
    }
    
    func generateCSV() -> URL {
        let csvString = generateCSVString()
        let fileName: String
        if ownership == .owned {
            fileName = "Music Collection.csv"
        }
        else {
            fileName = "Music Wantlist.csv"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
//            let drop = Drop(title: "Failed to generate CSV file",  icon: UIImage(systemName: "xmark"))
//            Drops.show(drop)
        }
        return url
    }
    
    func generateCSVString() -> String {
        var csv = "Title,Artist,Format,Release Date,Country,Genre,Style,Label,Cat No.,Description,Value,Date Added,Notes\n"
        
        for media in filteredCollection {
            let preview = media.mediaPreview
            let release = media.release
            
            let title = release?.title ?? preview.title ?? ""
            let artist = release?.artists.first?.name ?? ""
            let label = preview.label.joined(separator: " / ").replacingOccurrences(of: ",", with: " ")
            let format = preview.format.joined(separator: " / ").replacingOccurrences(of: ",", with: " ")
            let releaseDate = release?.released_formatted ?? (release?.year != nil ? String(release!.year!) : "")
            let country = preview.country ?? release?.country ?? ""
            let genre = preview.genre.joined(separator: " / ").replacingOccurrences(of: ",", with: " ")
            let style = preview.style.joined(separator: " / ").replacingOccurrences(of: ",", with: " ")
            let catno = preview.catno ?? release?.labels.first?.catno ?? ""
            let value = media.value != nil ? "\(media.value!)" : ""
            let description = (media.notes + (release?.notes ?? "")).replacingOccurrences(of: ",", with: " ")
            let dateAdded = media.dateFormatted
            let notes = media.notes
            
            let row = [title, artist, format, releaseDate, country, genre, style, label, catno, description, value, dateAdded, notes]
                .map { "\"\($0)\"" } // wrap fields in quotes
                .joined(separator: ",")
            
            csv.append(row + "\n")
        }
        return csv
    }
}

//#Preview {
//    CollectionView()
//}

