//
//  PokemonLoadingView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-24.
//

import SwiftUI

public struct PokemonLoadingView: View {
  public init() {}

  @State private var pokemon: Pokemon?
  private let primaryRange = 1...1017
  private let secondaryRange = 10001...10275

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
        PokemonView(pokemon: $0)
      }
      Button("Load new Pokemon") {
        let die = Int.random(in: 1...10)
        id = .random(
          in: die < 9 ? primaryRange : secondaryRange
        )
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
