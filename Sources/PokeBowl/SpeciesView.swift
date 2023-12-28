//
//  PokemonView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct SpeciesView: View {
  let species: Species

  @State private var variety: Pokemon?

  @State private var showingEvolutions = false

  public var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(
          url: variety?.imageURL
        ) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          ProgressView()
        }
        .padding()
        Text((variety?.name ?? species.name).localizedCapitalized)
          .bold()
          .opacity(species.varieties.count == 1 ? 1 : 0)
        Picker("Select a variety", selection: $variety) {
          ForEach(species.varieties) {
            Text($0.name.localizedCapitalized)
              .tag($0 as Pokemon?)
          }
        }
        .opacity(species.varieties.count > 1 ? 1 : 0)
        Button("Evolution chain") {
          showingEvolutions = true
        }
        .opacity(species.evolutions.isEmpty ? 0 : 1)
        .confirmationDialog("Select an evolution", isPresented: $showingEvolutions, titleVisibility: .visible) {
          ForEach(species.evolutions) { destinationSpecies in
            NavigationLink(destination: SpeciesView(species: destinationSpecies)) {
              Text(destinationSpecies.name.localizedCapitalized)
            }
          }
        }
        HStack {
          ForEach(variety?.types ?? [], id: \.self) {
            Text($0.type.name)
          }
        }
      }
      .padding()
      .onChange(of: species) {
        variety = species.varieties.first
      }
      .onAppear {
        variety = species.varieties.first
      }
    }
  }
}

#Preview {
  SpeciesView(
    species: .init(
      id: 1,
      name: "Test",
      varieties: [
        .init(
          id: 1,
          name: "Foo",
          imageURL: .init(string: "https://placekitten.com/408/287")!,
          types: []
        ),
      ],
      evolutions: []
    )
  )
}
