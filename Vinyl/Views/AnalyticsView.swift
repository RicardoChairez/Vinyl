//
//  AnalyticsView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/15/25.
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var saved: [Media]
    @State var collectionValue: Double = 0.0
    @State var collection: [Media] = []
    @State var collectionStates: [CollectionState] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30){
                    GroupBox {
                        VStack(alignment: .leading, spacing: 0){
                            Text("ALBUMS")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding(.bottom, 5)
                            
                            Text("\(collection.count) Collected")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(saved.count - collection.count) Wanted")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .backgroundStyle(.offPrimary)
                    .padding(.horizontal)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 0){
                            Text("COLLECTION VALUE")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding(.bottom, 5)
                            
                            Text("$\(String(format: "%.2f", collectionValue))")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            Chart(collectionStates, id:\.addedMedia.id) { item in
                                LineMark (
                                    x: .value("Date", item.addedMedia.dateAdded),
                                    y: .value("Profit A", item.value)
//                                        series: .value("Company", "A")
                                )
                                .symbol(.circle)
                                .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
//                            .chartYAxisLabel(position: .trailing, alignment: .center) {
//                                Text("Value")
//                            }
//                            .chartXAxisLabel(position: .bottom, alignment: .center) {
//                                Text("Date")
//                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal)
                    .backgroundStyle(.offPrimary)
                }
            }
            .navigationTitle("Analytics")
        }
        .onAppear {
            updateAnalytics()
        }
        .modelContainer(for: Media.self)
    }
    
    func updateAnalytics() {
        getCollection()
        getCollectionValue()
    }
    func getCollection() {
        collection = saved.filter({$0.ownership == .owned}).sorted(by: {$0.dateAdded < $1.dateAdded})
    }
    
    func getCollectionValue() {
        collectionValue = collection.map({$0.value ?? 20.0}).reduce(0.0, +)
        
        collectionStates = []
        var value = 0.0
        for media in collection {
            value = value + (media.value ?? 25.0) 
            collectionStates.append(CollectionState(addedMedia: media, value: value))
        }
    }
}

struct CollectionState {
    var id = UUID()
    
    let addedMedia: Media
    let value: Double
}
