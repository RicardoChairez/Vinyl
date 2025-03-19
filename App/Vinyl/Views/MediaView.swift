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
    @StateObject var vm: MediaViewModel
    @State var colors: [Color] = []
    @State var valueOpacity = 0.0
    
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
                                            getColorsFromImage(uiImage)
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
                            VStack(alignment: .leading, spacing: 5){
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
                                .padding(.bottom, 5)
                                
                                HStack {
                                        Group {
                                            Group {
                                                if vm.media.ownership == .owned {
                                                    Text(Ownership.owned.rawValue)
                                                        .foregroundStyle(.blue)
                                                }
                                                else if vm.media.ownership == .wanted {
                                                    Text(Ownership.wanted.rawValue)
                                                        .foregroundStyle(.yellow)
                                                }
                                                else {
                                                    Text(Ownership.unowned.rawValue)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .fontWeight(.semibold)
                                            .padding(4)
                                            .background(.notPrimary)
                                            .clipShape(.capsule)
                                            
                                            if vm.media.ownership == .owned {
                                                Text("\(vm.media.dateFormatted)")
                                            }
                                        }
                                        .font(.caption2)
                                        .padding(.bottom, 10)
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        
                                        Group {
                                            Text(vm.media.mediaPreview.country ?? "")
                                            HStack {
                                                Text(vm.media.release?.released_formatted ?? "")
                                                Text(vm.media.release?.label ?? "")
                                            }
                                            Text("CATNO: \(vm.media.mediaPreview.catno)")
                                        }
                                        .lineLimit(1)
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    if let value = vm.media.value {
                                        VStack {
                                            Text("VALUE")
                                                .foregroundStyle(.secondary)
                                                .font(.caption2)
                                            Text("$" + String(format: "%.2f", value) + " ")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .opacity(valueOpacity)
                                        .onAppear {
                                            withAnimation(.easeIn){
                                                valueOpacity = 1.0
                                            }
                                        }
                                        .fontWeight(.semibold)
                                    }
                                }
                                .padding(.bottom, 10)
                                
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
                                    .padding(.bottom, 2)
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
                                .padding(.bottom, 10)
                                
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
                                    .padding(.bottom, 10)
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
                                        }
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
            .confirmationDialog("Are you sure you want to remove this?", isPresented: $vm.removeIsConfirming){
                Button("Remove", role: .destructive) {
                    removeFromSave()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove?")
            }
            .sheet(isPresented: $vm.editIsPresented, onDismiss: {
                update()
            }, content: {
                EditMediaView(media: $vm.media)
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu{
                        switch vm.media.ownership {
                        case .owned:
                            Button{
                                vm.editIsPresented = true
                            } label: {
                                HStack {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }
                            }
                            Button(role: .destructive) {
                                vm.removeIsConfirming = true
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
                                vm.removeIsConfirming = true
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
                                .frame(width: 13, height: 13)
                        }
                        .foregroundStyle(Color.primary)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .tint(.offPrimary)
                        
                    }
                    .disabled(vm.media.release == nil)
                }
            })
            .modelContainer(for: Media.self)
        }
        .onAppear {
            if !vm.viewDidLoad {
                syncMediaWithStoredModel()
                Task {
                    await getData()
                }
            }
        }
    }
    
    func getData() async {
        async let release = vm.fetchRelease()
        async let otherVersion = vm.fetchOtherVersions(query: vm.media.mediaPreview.title)
        async let coverImageData = vm.fetchCoverImageData()
        
        do {
            let (fetchedRelease, fetchedOtherVersions, fetchedCoverImageData) = try await (release, otherVersion, coverImageData)
            
            vm.media.release = fetchedRelease
            vm.otherVersions = fetchedOtherVersions
            if vm.media.coverImageData == nil {
                withAnimation(.easeIn) {
                    vm.media.coverImageData = fetchedCoverImageData
                }
            }
            
            vm.media.value = await vm.getEstimatedPrice()
            await vm.getOtherVersionsImageData()
            
        }
        catch {
            let drop = Drop(title: "Error", subtitle: error.localizedDescription, subtitleNumberOfLines: 2)
            Drops.show(drop)
        }
        
        vm.viewDidLoad = true
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
    
    func update() {
        do {
            Drops.hideAll()
            modelContext.insert(vm.media)
            try modelContext.save()
        }
        catch {
            print(error.localizedDescription)
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
            withAnimation(.easeIn){
                colors = Array(dominantColorsInImage(cgImage).map({Color(cgColor: $0)})[0..<4])
            }
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
