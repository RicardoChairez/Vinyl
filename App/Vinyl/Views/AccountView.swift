//
//  AccountView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/13/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("FEEDBACK") {
                    HStack {
                        Image(systemName: "envelope")
                        Button {
                            
                        } label: {
                            Text("rdc257@nau.edu")
                        }
                        .tint(.blue)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AccountView()
}
