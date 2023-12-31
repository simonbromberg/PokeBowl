//
//  EvolutionView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct EvolutionView: View {
  let inset: String
  let evolution: Evolution

  init(inset: String = "", evolution: Evolution) {
    self.inset = inset
    self.evolution = evolution
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        NavigationLink(destination: SpeciesView(species: evolution.species, evolution: evolution)) {
          Text(inset + "• " + evolution.species.name.localizedCapitalized)
        }
        ForEach(evolution.evolvesTo) {
          EvolutionView(inset: inset + "  ", evolution: .init(species: $0.species, evolvesTo: $0.evolvesTo))
        }
      }
    }
  }
}

#Preview {
  EvolutionView(evolution: .test)
}
