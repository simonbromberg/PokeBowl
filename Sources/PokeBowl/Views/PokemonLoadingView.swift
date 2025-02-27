//
//  PokemonLoadingView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-24.
//

import SwiftUI

struct PokemonLoadingView: View {
  @State private var response: (Species, Evolution)?

  @State private var id: Int = .randomPokemonId() {
    didSet {
      loadPokemon()
    }
  }

  func loadPokemon() {
    Task {
      do {
        response = try await Networking.shared.loadPokemon(id: id)
      } catch {
        print("Pokemon id: \(id)")
        print(error)
      }
    }
  }

  var body: some View {
    VStack {
      response.map {
        SpeciesView(species: $0.0, evolution: $0.1)
      }
      Button("🔄 Load new Pokemon") {
        id = .randomPokemonId()
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
    }
    .onAppear {
      loadPokemon()
    }
  }
}

extension Int {
  static func randomPokemonId() -> Int {
    .random(in: .pokemonIds)
  }
}

extension ClosedRange where Bound == Int {
  static let pokemonIds = 1...1025
}

#Preview {
  PokemonLoadingView()
}
