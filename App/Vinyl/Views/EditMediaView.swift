//
//  EditMediaView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/13/25.
//

import SwiftUI

struct EditMediaView: View {
    @Environment(\.dismiss) private var dismiss
    
    init(media: Binding<Media>) {
        _media = media
    }
    
    @Binding var media: Media
    var valueColor: Color {
        if !media.customValueFlag {
            return Color.secondary
        }
        return Color.primary
    }
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        DatePicker("Date Collected:", selection: $media.dateAdded, displayedComponents: .date)
                    }
                    
                    Section {
                        HStack {
                            Text("Value:")
                            TextField("$0.00", value: $media.value, format: .currency(code: "USD"))
                                .foregroundStyle(valueColor)
                                .multilineTextAlignment(.trailing)
                                .disabled(!media.customValueFlag)
                                .keyboardType(.decimalPad)
                        }
                        Toggle("Custom Value", isOn: $media.customValueFlag)
                            .tint(.green)
                    }
                    Section {
                        TextField("Notes", text: $media.notes, axis: .vertical)
                            .background(.clear)
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .padding(.top)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done"){
                        self.dismiss()
                    }
                }
            })
            .navigationTitle(media.release?.title ?? "Edit Album")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    EditMediaView()
//}
