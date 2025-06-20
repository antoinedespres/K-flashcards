//
//  Card.swift
//  Flashzilla
//
//  Created by Antoine Després on 17/06/2025.
//

struct Card : Codable {
    
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "Who created 한글?", answer: "King Sejong")
}
