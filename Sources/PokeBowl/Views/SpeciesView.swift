//
//  SpeciesView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct SpeciesView: View {
  let species: Species
  let evolution: Evolution

  @State private var variety: Pokemon?
  @State private var imageIndex = 0

  @State private var showingEvolutions = false

  private var noEvolutions: Bool {
    evolution.evolvesTo.isEmpty
  }

  var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(
          url: (variety?.images[imageIndex]).flatMap { .init(string: $0) }
        ) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          ProgressView()
        }
        .onTapGesture {
          imageIndex = (imageIndex + 1) % (variety?.images.count ?? 0)
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
        NavigationLink(destination: EvolutionView(evolution: evolution)) {
          Text("Evolution Chain")
        }
        .opacity(noEvolutions ? 0 : 1)
        Text("No evolutions")
          .opacity(noEvolutions ? 1 : 0)
        HStack {
          ForEach(variety?.types ?? [], id: \.self) {
            Text($0.type.name)
          }
        }
      }
      .padding()
      .onChange(of: species) {
        variety = species.varieties.first
        imageIndex = 0
      }
      .onAppear {
        variety = species.varieties.first
      }
    }
  }
}

#Preview {
  SpeciesView(
    species: .test,
    evolution: .init(species: .test, evolvesTo: [])
  )
}
