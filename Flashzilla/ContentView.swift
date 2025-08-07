//
//  ContentView.swift
//  Flashzilla
//
//  Created by Antoine Després on 17/06/2025.
//  Based on the Flashzilla project, part of the 100 Days of SwiftUI class by Paul Hudson
//  https://www.hackingwithswift.com/books/ios-swiftui/flashzilla-introduction

import SwiftUI
internal import Combine

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    @State private var showingEditScreen = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isActive = true
    @State private var currentHour: Double = getCurrentHour()
    
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: gradientColors(for: currentHour)),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibilityHidden(index < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect.")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen) {
            JsonFilePickerView { selectedFilename in
                if let filename = selectedFilename {
                    loadRemoteCards(from: filename)
                }
            }
        }
        .onAppear(perform: resetCards)
    }
    
    func loadRemoteCards(from filename: String) {
        print("ran in content view")
        let url = Constants.remoteServerURL.appendingPathComponent(filename)
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                    DispatchQueue.main.async {
                        self.cards = decoded
                        if let encoded = try? JSONEncoder().encode(decoded) {
                            UserDefaults.standard.set(encoded, forKey: "Cards")
                        }
                        resetCards()
                    }
                }
            }
        }.resume()
    }
    
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    static func getCurrentHour() -> Double {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour], from: now)
        let hour = Double(components.hour ?? 0)
        return hour
    }
    
    // App background
    func gradientColors(for hour: Double) -> [Color] {
        switch hour {
        case 0..<6:
            return [Color.black, Color.blue.opacity(0.4)]
        case 6..<9:
            return [Color.orange, Color.pink]
        case 9..<12:
            return [Color.blue, Color.cyan]
        case 12..<15:
            return [Color.cyan, Color.yellow]
        case 15..<18:
            return [Color.orange, Color.purple]
        case 18..<20:
            return [Color.pink, Color.indigo]
        case 20..<24:
            return [Color.blue.opacity(0.8), Color.black]
        default:
            return [Color.gray, Color.black]
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

#Preview {
    ContentView()
}
