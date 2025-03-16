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
    @State var formatCounts: [FormatCount] = [FormatCount(format: "Vinyl", count: 0), FormatCount(format: "CD", count: 0), FormatCount(format: "Cassette", count: 0), FormatCount(format: "DVD", count: 0), FormatCount(format: "File", count: 0)]
    
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
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(collection.count) Collected")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Text("\(saved.count - collection.count) Wanted")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                CircularProgressView(progress: Double(collection.count) / Double(saved.count))
                                    .frame(width: 35, height: 35)
                            }
                            
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
                                .foregroundStyle(.green)
                            
                            Chart(collectionStates, id:\.addedMedia.id) { item in
                                LineMark (
                                    x: .value("Date", item.addedMedia.dateAdded),
                                    y: .value("Profit A", item.value)
                                )
                                .symbol(.circle)
                                .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal)
                    .backgroundStyle(.offPrimary)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 0){
                            Text("COLLECTION STATS")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding(.bottom, 5)
                            
                            Text("Format")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            Chart(formatCounts, id: \.format) { item in
                                BarMark(x: .value("Format", item.format), y: .value("Count", item.count))
                                    .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .backgroundStyle(.offPrimary)
                    .padding(.horizontal)
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
        getCollectionStates()
        getFormatCounts()
    }
    func getCollection() {
        collection = saved.filter({$0.ownership == .owned}).sorted(by: {$0.dateAdded < $1.dateAdded})
    }
    
    func getCollectionValue() {
        collectionValue = collection.map({$0.value ?? 20.0}).reduce(0.0, +)
    }
    
    func getCollectionStates() {
        collectionStates = []
        var value = 0.0
        for media in collection {
            value = value + (media.value ?? 25.0)
            collectionStates.append(CollectionState(addedMedia: media, value: value))
        }
    }
    
    func getFormatCounts() {
        formatCounts = [FormatCount(format: "Vinyl", count: 0), FormatCount(format: "CD", count: 0), FormatCount(format: "Cassette", count: 0), FormatCount(format: "DVD", count: 0), FormatCount(format: "File", count: 0)]
        for media in collection {
            if media.mediaPreview.formatSet.contains("Vinyl"){
                formatCounts[0].increment()
            }
            else if media.mediaPreview.formatSet.contains("CD") || media.mediaPreview.formatSet.contains("CDr") {
                formatCounts[1].increment()
            }
            else if media.mediaPreview.formatSet.contains("Cassette") {
                formatCounts[2].increment()
            }
            else if media.mediaPreview.formatSet.contains("DVD") {
                formatCounts[3].increment()
            }
            else if media.mediaPreview.format.contains("File") {
                formatCounts[4].increment()
            }
        }
        formatCounts.sort(by: {$0.count > $1.count})
    }
}

struct CollectionState {
    let addedMedia: Media
    let value: Double
}

struct FormatCount {
    let format: String
    var count: Int
    
    mutating func increment() {
        count = count + 1
    }
}
