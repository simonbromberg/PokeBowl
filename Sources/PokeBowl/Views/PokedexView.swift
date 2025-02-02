//
//  PokedexView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2025-02-02.
//

import SwiftUI

struct PokedexView: View {
  let columns = Array(repeating: GridItem(.flexible()), count: 3)
  @State private var pokemons = [Int: (Species, Evolution)]()
  @State private var selectedPokemon: Int? = nil

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns) {
        ForEach(ClosedRange.pokemonIds, id: \.self) { pokemonId in
          if let pokemon = pokemons[pokemonId], let image = pokemon.0.varieties.first?.images.first {
            PokemonImage(url: image)
              .onTapGesture {
                selectedPokemon = pokemonId
            }
          } else {
            ProgressView()
              .onAppear {
                Task {
                  try await loadPokemon(id: pokemonId)
                }
              }
          }
        }
      }
    }
    .onAppear {
      loadInitialPokemon()
    }
    .sheet(
      isPresented: .init(
        get: { selectedPokemon != nil },
        set: { _ in selectedPokemon = nil }
      )
    ) {
      let (species, evolution) = pokemons[selectedPokemon!]!
      SpeciesView(species: species, evolution: evolution)
    }
  }

  func loadInitialPokemon() {
    Task {
      for i in 1..<100 {
        await loadPokemon(id: i)
      }
    }
  }

  func loadPokemon(id: Int) async {
    do {
      let response = try await Networking.shared.loadPokemon(id: id)
      pokemons[id] = response
    } catch {
      print("Pokemon id: \(id)")
      print(error)
    }
  }
}

struct PokemonImage: View {
  let url: String

  @State private var image: UIImage?

  var body: some View {
    if let image = image {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
    } else {
      ProgressView()
        .onAppear {
          Task {
            try await loadImage()
          }
        }
    }
  }
  

  func loadImage() async throws {
    let data = try await Networking.shared.loadImageData(url)
    self.image = try UIImage(data: data).unwrap()
  }
}

#Preview {
  PokedexView()
}
