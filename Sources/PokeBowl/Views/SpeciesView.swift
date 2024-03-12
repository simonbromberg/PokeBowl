//
//  SpeciesView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct SpeciesView: View {
  let species: Species
  let evolution: Evolution?

  @State private var variety: Pokemon?
  @State private var imageIndex = 0

  @State private var showingEvolutions = false

  private var noEvolutions: Bool {
    evolution?.evolvesTo.isEmpty == true
  }

  var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(
          url: (variety?.images[imageIndex]).flatMap { .init(string: $0) }
        ) { phase in
          if let image = phase.image {
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
          } else if phase.error != nil {
            // TODO: error
          } else {
            // placeholder
          }
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
        Button("🧬 Evolution Chain") {
          showingEvolutions.toggle()
        }
        .sheet(isPresented: $showingEvolutions) {
          evolution.map { e in
            VStack {
              Text("\(species.name.localizedCapitalized) Evolutions")
                .font(.title)
                .padding()
              EvolutionView(evolution: e)
              Button {
                showingEvolutions.toggle()
              } label: {
                 Image(systemName: "xmark.circle")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .tint(.primary)
              }
            }
          }
        }
        .opacity((evolution == nil || noEvolutions) ? 0 : 1)
        Text("No evolutions")
          .opacity(noEvolutions ? 1 : 0)
        HStack {
          ForEach(variety?.types ?? [], id: \.self) {
            Text($0.type.name)
              .foregroundStyle(Color.secondary)

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
