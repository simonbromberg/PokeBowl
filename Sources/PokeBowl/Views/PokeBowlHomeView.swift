//
//  PokeBowlHomeView.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-31.
//

import SwiftUI

public struct PokeBowlHomeView: View {
  public init() {}

  public var body: some View {
    TabView {
      PokemonLoadingView()
        .tabItem {
          Label("Pokedex", systemImage: "book")
        }
      PokemonMatchingGame()
        .tabItem {
          Label("Matching", systemImage: "rectangle.on.rectangle.circle")
        }
    }
  }
}

#Preview {
  PokeBowlHomeView()
}
