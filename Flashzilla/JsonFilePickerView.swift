//
//  JsonFilePicketView.swift
//  Flashzilla
//
//  Created by Antoine Després on 20/06/2025.
//

import SwiftUI

struct JsonFilePickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var remoteFiles = [String]()
    @State private var isLoading = true
    
    var onSelect: (String?) -> Void

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Fetching JSON...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(remoteFiles, id: \.self) { filename in
                        Button(action: {
                            onSelect(filename)
                            dismiss()
                        }) {
                            Text(filename)
                        }
                    }
                }
            }
            .navigationTitle("Load Card Pack")
            .onAppear(perform: fetchRemoteFileList)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onSelect(nil)
                        dismiss()
                    }
                }
            }
        }
    }

    func fetchRemoteFileList() {
        let url = Constants.remoteJsonFileListURL

        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { DispatchQueue.main.async { isLoading = false } }

            if let data = data {
                if let fileList = try? JSONDecoder().decode([String].self, from: data) {
                    DispatchQueue.main.async {
                        self.remoteFiles = fileList
                    }
                }
            }
        }.resume()
    }

}
