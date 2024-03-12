//
//  PokemonLoadingView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-24.
//

import SwiftUI

struct PokemonLoadingView: View {
  @State private var response: (Species, Evolution)?

  private let idRange = 1...1025

  @State private var id = 1 {
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
        id = .random(in: idRange)
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)
    }
    .onAppear {
      loadPokemon()
    }
  }
}

#Preview {
  PokemonLoadingView()
}
