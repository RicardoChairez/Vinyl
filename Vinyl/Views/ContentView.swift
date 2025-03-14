//
//  ContentView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import SwiftUI

enum TabScreen {
    case collection, wishlist, search
}

struct ContentView: View {
    
    @State private var tab: TabScreen = .collection
    
    var body: some View {
        TabView(selection: $tab){
            
            Tab("Collection", systemImage: "music.note.list", value: TabScreen
.collection){
                MediasView(ownership: .owned)
            }
            Tab("Wishlist", systemImage: "list.bullet", value: TabScreen
.collection){
                MediasView(ownership: .wanted)
            }
            Tab("Search", systemImage: "magnifyingglass", value: TabScreen
.collection){
                SearchView()
            }
        }
        .tint(.primary)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
}
