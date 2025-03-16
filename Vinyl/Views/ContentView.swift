//
//  ContentView.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import SwiftUI

enum TabScreen {
    case collection, analytics, wantlist, search
}

struct ContentView: View {
    
    @State private var tab: TabScreen = .collection
    
    var body: some View {
        TabView(selection: $tab){
            
            Tab("Collection", systemImage: "music.note.list", value: TabScreen.collection){
                MediasView(ownership: .owned)
            }
            Tab("Wantlist", systemImage: "list.bullet", value: TabScreen.wantlist){
                MediasView(ownership: .wanted)
            }
            Tab("Analytics", systemImage: "chart.line.uptrend.xyaxis", value: TabScreen.analytics) {
                AnalyticsView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: TabScreen.search){
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
