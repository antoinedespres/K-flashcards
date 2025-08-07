//
//  EditCards.swift
//  Flashzilla
//
//  Created by Antoine Després on 20/06/2025.
//  Unused file

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    @State private var remoteFiles = [String]()
    
    let remoteServerURL = Constants.remoteServerURL
    
    var body: some View {
        NavigationStack {
            List(remoteFiles, id: \.self) { filename in
                Button(filename) {
                    loadRemoteCards(from: filename)
                    dismiss()
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
            .onAppear(perform: loadData)
        }
    }
    
    func done() {
        dismiss()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }
        
        let card = Card(theme: "", prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(card, at: 0)
        newPrompt.removeAll()
        newAnswer.removeAll()
        saveData()
    }
    
    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
    
    func fetchRemoteFileList() {
        let url = Constants.remoteJsonFileListURL
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let fileList = try? JSONDecoder().decode([String].self, from: data) {
                    DispatchQueue.main.async {
                        self.remoteFiles = fileList
                    }
                }
            }
        }.resume()
    }
    func loadRemoteCards(from filename: String) {
        let url = Constants.remoteServerURL.appendingPathComponent(filename)
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                    DispatchQueue.main.async {
                        self.cards = decoded
                        // optionally persist to UserDefaults
                        if let encoded = try? JSONEncoder().encode(decoded) {
                            UserDefaults.standard.set(encoded, forKey: "Cards")
                        }
                    }
                }
            }
        }.resume()
    }
}
