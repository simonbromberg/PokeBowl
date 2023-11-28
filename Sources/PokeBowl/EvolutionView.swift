//
//  EvolutionView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

public struct EvolutionView: View {
  public init(id: Int) { self.id = id }

  let id: Int
  public var body: some View {
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
