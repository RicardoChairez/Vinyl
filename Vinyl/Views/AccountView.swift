//
//  AccountView.swift
//  Vinyl
//
//  Created by Chip Chairez on 3/13/25.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text("HI")
                }
                Section("HI") {
                    
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
