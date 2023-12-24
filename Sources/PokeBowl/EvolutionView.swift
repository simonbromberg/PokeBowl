//
//  EvolutionView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import SwiftUI

public struct EvolutionView: View {
  let evolutions: [Pokemon]

  public var body: some View {
    VStack {
      ForEach(evolutions) {
        Text($0.name)
      }
    }
  }
}

#Preview {
  EvolutionView(evolutions: [])
}
