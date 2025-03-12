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
    init(searchText: String = "", isInCollection: Bool) {
        self.searchText = searchText
        self.isInCollection = isInCollection
        if isInCollection {
            self.title = "Collection"
        }
        else {
            self.title = "Wishlist"
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query var collection: [Media]
    @State var searchText = ""
    @State var accountIsPresented = false
    let isInCollection: Bool
    let title: String
    var filteredCollection: [Media] {
        var filteredCollection = collection.filter({$0.isInCollection == self.isInCollection})
        filteredCollection = sortCollection(collection: filteredCollection)
        if searchText.isEmpty {
            return filteredCollection
        }
        else {
            let lowercasedSearchText = searchText.lowercased()
            filteredCollection = filteredCollection.filter { media in
                media.release!.title.lowercased().contains(lowercasedSearchText) ||
                media.release!.artists.contains(where: {$0.name?.lowercased().contains(lowercasedSearchText) ?? false}) ||
                media.mediaPreview.genre.contains(where: {$0.lowercased().contains(lowercasedSearchText)}) ||
                media.mediaPreview.format.contains(where: {$0.lowercased().contains(lowercasedSearchText)})
            }
        }
        return filteredCollection
    }
    @State var selectedSort: Sort = .added
    
    
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
                                        Text(media.release?.title ?? media.mediaPreview.title )
                                        Text(media.release?.artists.first?.name ?? "")
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    
                                }
                            }
                        }
                        .tint(.primary)
                        .contextMenu {
                            if !isInCollection {
                                Button("Add to collection") {
                                    withAnimation {
                                        addToCollection(media: media)
                                    }
                                }
                            }
                            Button("Remove", role: .destructive) {
                                withAnimation {
                                    removeFromCollection(media: media)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .sheet(isPresented: $accountIsPresented, content: {
                Text("HI")
            })
            .searchable(text: $searchText, prompt: "Album, Format, Genre, Artist")
            .navigationDestination(for: Media.self) { media in
                MediaView(vm: MediaViewModel(mediaModel: media))
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
                    Menu {
                        Picker(selection: $selectedSort) {
                            ForEach(Sort.allCases, id: \.self) { sort in
                                Text(sort.localizedName)
                                    .tag(sort)
                            }
                        } label: {
                            
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .modelContainer(for: Media.self)
    }
    
    func removeFromCollection(media: Media) {
        do {
            modelContext.delete(media)
            try modelContext.save()
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
            media.isInCollection = true
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
        switch selectedSort {
        case .label:
            return collection.sorted(by: {($0.release?.labels.first?.name ?? "") < ($1.release!.labels.first?.name ?? "")})
        case .artist:
            return collection.sorted(by: {($0.release?.artists.first?.name ?? "") < ($1.release!.artists.first?.name ?? "")})
        case .title:
            return collection.sorted(by: {$0.release!.title < $1.release!.title})
        case .added:
            return collection.sorted(by: {$0.dateAdded > $1.dateAdded})
        case .year:
            return collection.sorted(by: {$0.mediaPreview.year ?? "" < $1.mediaPreview.year ?? ""})
        }
    }
}

//#Preview {
//    CollectionView()
//}

