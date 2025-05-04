//
//  DocumentExporterView.swift
//  Vinyl
//
//  Created by Chip Chairez on 5/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentExporterView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forExporting: [fileURL])
        controller.shouldShowFileExtensions = true
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
