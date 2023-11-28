//
//  EvolutionView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

struct EvolutionView: View {
  let id: Int
  var body: some View {
    VStack {
      Text("id: \(id)")
    }.onAppear {
//      Task {
//        try await Networking.shared.loadEvolution(id)
//      }
    }
  }
}

#Preview {
  EvolutionView(id: 1)
}
