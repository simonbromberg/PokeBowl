//
//  PokemonView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct PokemonView: View {
  let pokemon: Pokemon
  @State private var showingEvolutions = false

  public var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(
          url: pokemon.imageURL
        ) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          ProgressView()
        }
        .padding()
        Text(pokemon.name.localizedCapitalized)
          .bold()
        Button("Evolutions") {
          showingEvolutions = true
        }
        .opacity(pokemon.evolutions.isEmpty ? 0 : 1)
        .confirmationDialog("Select an evolution", isPresented: $showingEvolutions, titleVisibility: .visible) {
          ForEach(pokemon.evolutions) { pokemon in
            NavigationLink(destination: PokemonView(pokemon: pokemon)) {
              Text(pokemon.name.localizedCapitalized)
            }
          }
        }
        HStack {
          ForEach(pokemon.types, id: \.self) {
            Text($0.type.name)
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  PokemonView(pokemon: .init(id: 1, name: "Test", evolutions: [], imageURL: .init(string: "https://placekitten.com/408/287")!, types: []))
}
