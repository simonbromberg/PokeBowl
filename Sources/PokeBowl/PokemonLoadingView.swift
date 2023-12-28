//
//  PokemonLoadingView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-24.
//

import SwiftUI

public struct PokemonLoadingView: View {
  public init() {}

  @State private var pokemon: Species?
  private let idRange = 1...1025

  @State private var id = 1 {
    didSet {
      loadPokemon()
    }
  }

  func loadPokemon() {
    Task {
      do {
        pokemon = try await Networking.shared.loadPokemon(id)
      } catch {
        print("Pokemon id: \(id)")
        print(error)
      }
    }
  }

  public var body: some View {
    VStack {
      pokemon.map {
        SpeciesView(species: $0)
      }
      Button("Load new Pokemon") {
        id = .random(in: idRange)
      }
    }
    .onAppear {
      loadPokemon()
    }
  }
}

#Preview {
    PokemonLoadingView()
}
