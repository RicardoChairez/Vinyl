//
//  MediaView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import SwiftUI
import SwiftData
import DominantColor
import Drops

struct MediaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var collection: [Media]
    @State var colors: [Color] = []
    @StateObject var vm: MediaViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if !colors.isEmpty {
                    RadialGradient(gradient: Gradient(colors: colors), center: .top, startRadius: 0, endRadius: 700)
                        .ignoresSafeArea(.all)
                        .blur(radius: 10, opaque: true)
                }
                ScrollView {
                    VStack(spacing: 20) {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: proxy.size.width - 60)
                            .overlay {
                                if let imageData = vm.media.coverImageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .task {
                                            print(vm.media.mediaPreview.cover_image)
                                            withAnimation(.easeIn) {
                                                getColorsFromImage(uiImage)
                                            }
                                        }
                                }
                                else {
                                    Color.secondary
                                }
                            }
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.2), radius: 2)
                            .clipped()
                        
                        VStack {
                            VStack( alignment: .leading ){
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text(vm.media.release?.artists.first?.name ?? "")
                                            .foregroundStyle(.secondary)
                                            .font(.headline)
                                        Spacer()
                                        Menu{
                                            if isInCollection() {
                                                Button("Remove from collection", role: .destructive) {
                                                    removeFromCollection()
                                                }
                                            }
                                            else {
                                                Button("Add to Collection") {
                                                    save(isInCollection: true)
                                                }
                                            }
                                            
                                            if !isSaved() {
                                                Button("Add to Wishlist") {
                                                    save(isInCollection: false)
                                                }
                                            }
                                            else if !isInCollection() {
                                                Button("Remove from wishlist", role: .destructive) {
                                                    removeFromCollection()
                                                }
                                            }
                                            
                                        } label: {
                                            Image(systemName: "ellipsis.circle")
                                                .disabled(vm.media.release == nil)
                                                .scaledToFit()
                                        }
                                    }
                                    
                                    Text(vm.media.release?.title ?? vm.media.mediaPreview.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(vm.media.mediaPreview.country ?? "")
                                    HStack {
                                        Text(vm.media.release?.released_formatted ?? "")
                                        Text(vm.media.release?.label ?? "")
                                    }
                                }
                                .frame(width: .infinity)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 5)
                                    
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(vm.media.mediaPreview.format, id: \.self) { format in
                                            HStack(spacing: 5){
                                                Image(systemName: "tag")
                                                Text(format)
                                            }
                                            .font(.caption)
                                            .padding(5)
                                            .background(.secondary)
                                            .clipShape(.capsule)
                                            
                                        }
                                    }
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(vm.media.mediaPreview.genre, id: \.self) { genre in
                                            HStack(spacing: 5){
                                                Image(systemName: "tag")
                                                Text(genre)
                                            }
                                            .font(.caption)
                                            .padding(5)
                                            .background(.secondary)
                                            .clipShape(.capsule)
                                        }
                                    }
                                }
                                .padding(.bottom, 5)
                                
                                if let notes = vm.media.release?.notes {
                                    VStack(alignment: .leading){
                                        Text(notes)
                                            .lineLimit(vm.descriptionLines)
                                            .foregroundStyle(.secondary)
                                        if vm.descriptionLines != nil {
                                            Button("MORE"){ vm.descriptionLines = nil}
                                                .foregroundStyle(.primary)
                                                .fontWeight(.semibold)
                                        }
                                        else {
                                            Button("LESS"){ vm.descriptionLines = 3}
                                                .foregroundStyle(.primary)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .font(.footnote)
                                    .padding(.bottom, 5)
                                }
                                
                                if let tracklist = vm.media.release?.tracklist {
                                    VStack(alignment: .leading){
                                        ForEach(tracklist, id: \.title) { track in
                                            Divider()
                                            HStack(spacing: 0){
                                                Text(track.position ?? "")
                                                    .frame(width: 25, alignment: .leading)
                                                    .foregroundStyle(.secondary)
                                                Text(track.title ?? "")
                                                Spacer()
                                                Text(track.duration ?? "")
                                            }
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            
                                        }
                                    }
                                    Divider()
                                        .padding(.bottom, 5)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.horizontal)
                        
                        if !vm.otherVersions.isEmpty {
                            VStack(alignment: .leading){
                                Text("Other releases")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .fontWeight(.semibold)
                                    .padding([.top, .leading])
                                
                                ForEach($vm.otherVersions) { $mediaPreview in
                                    NavigationLink(value: mediaPreview) {
                                        MediaPreviewView(mediaPreview: $mediaPreview)
                                            .padding(.leading)
                                    }
                                    //                            .task({await vm.downloadImage(mediaPreview)})
                                }
                            }
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .padding()
                        }
                    }
                    .navigationDestination(for: MediaPreview.self) { mediaPreview in
                        MediaView(vm: MediaViewModel(mediaPreview: mediaPreview, coverImageData: nil, isInCollection: false))
                    }
                    .background(.clear)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu{
                        if isInCollection() {
                            Button("Remove from collection", role: .destructive) {
                                removeFromCollection()
                            }
                        }
                        else {
                            Button("Add to Collection") {
                                save(isInCollection: true)
                            }
                        }
                        
                        if !isSaved() {
                            Button("Add to Wishlist") {
                                save(isInCollection: false)
                            }
                        }
                        else if !isInCollection() {
                            Button("Remove from wishlist", role: .destructive) {
                                removeFromCollection()
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .disabled(vm.media.release == nil)
                    }
                }
            })
            .modelContainer(for: Media.self)
        }
        .task {
            updateMedia()
            if let release = vm.media.release, vm.otherVersions.isEmpty{
                await vm.getOtherVersions(query: "\(release.title) \(release.artists.first?.name ?? "")")
            }
            else {
                await vm.downloadImage()
                await vm.getRelease()
            }
        }
    }
    
    func save(isInCollection: Bool) {
        do {
            Drops.hideAll()
            vm.media.isInCollection = isInCollection
            modelContext.insert(vm.media)
            updateMedia()
            try modelContext.save()
            let drop = Drop(title: "Successfully added", titleNumberOfLines: 1, subtitle: nil, subtitleNumberOfLines: 0, icon: UIImage(systemName: "checkmark"))
            Drops.show(drop)
        }
        catch {
            vm.media.isInCollection = false
            print(error.localizedDescription)
            let drop = Drop(title: Constants.drop.addToCollectionFailure, titleNumberOfLines: 1, subtitle: error.localizedDescription, subtitleNumberOfLines: 2, icon: UIImage(systemName: "xmark"))
            Drops.show(drop)
        }
    }
    
    
    func removeFromCollection() {
        do {
            if let media = collection.first(where: {$0.mediaPreview.id == vm.media.mediaPreview.id}) {
                modelContext.delete(media)
            }
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
    
    func getColorsFromImage(_ image: UIImage) {
        if let cgImage = image.cgImage {
            colors = Array(dominantColorsInImage(cgImage).map({Color(cgColor: $0)})[0..<4])
        }
    }
    
    func isSaved() -> Bool{
        return collection.contains(where: {$0.mediaPreview.id == vm.media.mediaPreview.id})
    }
    
    func isInCollection() -> Bool {
        if let media = collection.first(where: {$0.mediaPreview.id == vm.media.mediaPreview.id}) {
            return media.isInCollection
        }
        return false
    }
    
    func updateMedia() {
        if let media = collection.first(where: {$0.mediaPreview.id == vm.media.mediaPreview.id}) {
            vm.media = media
        }
    }
}

//#Preview {
//    let swag = Master(id: 2, genres: [""], styles: [""], year: 2, tracklist: [Track(position: "", title: "", duration: "")], artists: [Artist(name: "")], title: "")
//    
//    let media = Media(country: "US", year: "2022", formats: ["Vinyl", "LP", "Album", "Reissue", "Stereo"], label: ["Blonded", "Henson Recording Studios", "Blonded", "Blonded", "Precision Record Pressing", "GZ Media"], genres: ["Hip Hop", "Funk / Soul", "Pop"], style: ["Contemporary R&B"], mediaID: 25500877, masterId: 1046042, masterUrl: "https://api.discogs.com/masters/1046042", catno: "BLNDD002", title: "Frank Ocean - Blonde", thumb: "https://i.discogs.com/hVyL6xRararOpLFnJLceQrUrojtUCuPqQJjUywnRavA/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTI1NTAw/ODc3LTE2NzQ3Nzgy/MzgtMjgxMi5qcGVn.jpeg", coverImage: "https://i.discogs.com/sH-YzOU7BthEIPqaAI--Leza_7CRv6UiWWezvIaTN88/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTg5MzI1/MTQtMTQ3MTczNzEx/OS01MTU1LmpwZWc.jpeg")
//
//    MediaView(vm: MediaViewModel(media: media, coverImageData: nil))
//}
