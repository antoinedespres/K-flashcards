//
//  Card.swift
//  Flashzilla
//
//  Created by Antoine Després on 17/06/2025.
//

import Foundation

struct Card : Codable, Identifiable {
    var id = UUID()
    
    var theme: String
    var prompt: String
    var answer: String
    
    enum CodingKeys: String, CodingKey {
        case theme, prompt, answer
    }
    
    static let example = Card(theme: "Culture", prompt: "Who created 한글?", answer: "King Sejong")
}
