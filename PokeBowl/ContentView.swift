//
//  ContentView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct ContentView: View {
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
  
  var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(
          url: pokemon?.imageURL
        ) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          ProgressView()
        }
        .padding()
        Text(pokemon?.name.localizedCapitalized ?? "")
          .bold()
        NavigationLink(destination: EvolutionView(id: id)) {
          Text("Evolutions")
        }
        HStack {
          ForEach(pokemon?.types ?? [], id: \.self) {
            Text($0.type.name)
          }
        }
      }
      .padding()
      .onAppear {
        loadPokemon()
      }
      .onTapGesture {
        let die = Int.random(in: 1...10)
        id = Int.random(
          in: die < 9 ? primaryRange : secondaryRange
        )
      }
    }
  }
}

#Preview {
  ContentView()
}
