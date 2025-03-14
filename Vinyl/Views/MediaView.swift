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
    @State var viewDidLoad = false
    @State var editIsPresented = false
    
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
                                            withAnimation(.easeIn) {
                                                getColorsFromImage(uiImage)
                                            }
                                        }
                                }
                                else {
                                    Color.offPrimary
                                }
                            }
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.2), radius: 2)
                            .clipped()
                        
                        VStack {
                            VStack( alignment: .leading, spacing: 5 ){
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text(vm.media.release?.artists.first?.name ?? "")
                                            .foregroundStyle(.secondary)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    Text(vm.media.release?.title ?? vm.media.mediaPreview.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if vm.media.ownership != .unowned {
                                                Group {
                                                    Group {
                                                        if vm.media.ownership == .owned {
                                                            Text(Ownership.owned.rawValue)
                                                                .foregroundStyle(.blue)
                                                        }
                                                        else if vm.media.ownership == .wanted {
                                                            Text(Ownership.wanted.rawValue)
//                                                                .foregroundStyle(.yellow)
                                                        }
                                                    }
                                                    .foregroundStyle(.primary)
                                                    .font(.caption2)
                                                    .fontWeight(.semibold)
                                                    .padding(4)
                                                    .background(.notPrimary)
                                                    .clipShape(.capsule)
                                                    
                                                    if vm.media.ownership == .owned {
                                                        Text("on \(vm.media.dateFormatted)")
                                                            .font(.caption2)
                                                    }
                                                }
                                                .padding(.bottom, 5)
                                            }
                                        }
                                        
                                        Text(vm.media.mediaPreview.country ?? "")
                                        HStack {
                                            Text(vm.media.release?.released_formatted ?? "")
                                            Text(vm.media.release?.label ?? "")
                                        }
                                        Text("CATNO: \(vm.media.mediaPreview.catno)")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    VStack {
                                            Text("VALUE")
                                                .foregroundStyle(.secondary)
                                                .font(.caption2)
                                        Group {
                                            if let estimatedPrice = vm.media.estimatedValue {
                                                Text("$" + String(format: "%.2f", estimatedPrice) + " ")
                                            }
                                            else {
                                                Text("?")
                                            }
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                            Spacer()
                                    }
                                }
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
                                    .padding(.bottom, 5)
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
                                        Group {
                                            if vm.descriptionLines != nil {
                                                Text("MORE")
                                            }
                                            else {
                                                Text("LESS")
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        
                                    }
                                    .onTapGesture(perform: {
                                        vm.toggleDescription()
                                    })
                                    .font(.caption2)
                                    .padding(.bottom, 5)
                                }
                                
                                if let tracklist = vm.media.release?.tracklist {
                                    VStack(alignment: .leading){
                                        Text("TRACKLIST")
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.secondary)
                                        ForEach(tracklist, id: \.title) { track in
                                            Divider()
                                            HStack(spacing: 0){
                                                Text(track.position ?? "")
                                                    .frame(width: 30, alignment: .leading)
                                                    .foregroundStyle(.secondary)
                                                Text(track.title ?? "")
                                                Spacer()
                                                Text(track.duration ?? "")
                                            }
                                            .padding(.vertical, 5)
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
                                Group {
                                    Text("OTHER RELEASES")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .fontWeight(.semibold)
                                        .padding(.top)
                                    Divider()
                                    
                                    ForEach($vm.otherVersions) { $mediaPreview in
                                        NavigationLink(value: mediaPreview) {
                                            MediaPreviewView(mediaPreview: $mediaPreview)
//                                                .padding(.leading)
                                        }
                                        //                            .task({await vm.downloadImage(mediaPreview)})
                                    }
                                }
                                .padding(.leading)
                            }
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .padding()
                        }
                    }
                    .navigationDestination(for: MediaPreview.self) { mediaPreview in
                        MediaView(vm: MediaViewModel(mediaPreview: mediaPreview))
                    }
                    .background(.clear)
                }
            }
            .sheet(isPresented: $editIsPresented, content: {
                EditMediaView(media: $vm.media)
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu{
                        switch vm.media.ownership {
                        case .owned:
                            Button{
                                editIsPresented = true
                            } label: {
                                HStack {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }
                            }
                            Button(role: .destructive) {
                                removeFromSave()
                            } label: {
                                HStack {
                                    Text("Remove from Collection")
                                    Image(systemName: "trash")
                                }
                            }
                            
                        case .unowned:
                            Button {
                                save(ownership: .owned)
                            } label: {
                                HStack {
                                    Text("Add to Collection")
                                    Image(systemName: "plus")
                                }
                            }
                            Button {
                                save(ownership: .wanted)
                            } label: {
                                HStack {
                                    Text("Add to Wantlist")
                                    Image(systemName: "plus")
                                }
                            }
                        case .wanted:
                            Button {
                                save(ownership: .owned)
                            } label: {
                                HStack {
                                    Text("Add to Collection")
                                    Image(systemName: "plus")
                                }
                            }
                            Button(role: .destructive) {
                                removeFromSave()
                            } label: {
                                HStack {
                                    Text("Remove from Wantlist")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        
                    } label: {
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        }
                        .foregroundStyle(Color.primary)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .disabled(vm.media.release == nil)
                        .tint(.offPrimary)
                        
                    }
                }
            })
            .modelContainer(for: Media.self)
        }
        .onAppear {
            if !viewDidLoad {
                Task {
                    syncMediaWithStoredModel()
                    await vm.getEstimatedPrice()
                    if let release = vm.media.release {
                        if vm.otherVersions.isEmpty {
                                await vm.getOtherVersions(query: "\(release.title) \(release.artists.first?.name ?? "")")
                        }
                    }
                    else {
                            await vm.getRelease()
                    }
                    if vm.media.coverImageData == nil {
                            await vm.downloadImage()
                    }
                    self.viewDidLoad = true
                }
            }
        }
    }
    
    func save(ownership: Ownership) {
        let previousOwnership = vm.media.ownership
        do {
            Drops.hideAll()
            vm.media.ownership = ownership
            modelContext.insert(vm.media)
            try modelContext.save()
            syncMediaWithStoredModel()
            let drop = Drop(title: "Successfully added", titleNumberOfLines: 1, subtitle: nil, subtitleNumberOfLines: 0, icon: UIImage(systemName: "checkmark"))
            Drops.show(drop)
        }
        catch {
            vm.media.ownership = previousOwnership
            print(error.localizedDescription)
            let drop = Drop(title: Constants.drop.addToCollectionFailure, titleNumberOfLines: 1, subtitle: error.localizedDescription, subtitleNumberOfLines: 2, icon: UIImage(systemName: "xmark"))
            Drops.show(drop)
        }
    }
    
    
    func removeFromSave() {
        do {
            guard let media = collection.first(where: {$0.mediaPreview.id == vm.media.mediaPreview.id}) else {
                throw CustomError.notInCollection
            }
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
    
    func getColorsFromImage(_ image: UIImage) {
        if let cgImage = image.cgImage {
            colors = Array(dominantColorsInImage(cgImage).map({Color(cgColor: $0)})[0..<4])
        }
    }
    
    func isSaved() -> Bool{
        return collection.contains(where: {$0.mediaPreview.id == vm.media.mediaPreview.id})
    }
    
    func syncMediaWithStoredModel() {
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
