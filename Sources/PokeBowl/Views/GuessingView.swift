//
//  GuessingView.swift
//
//
//  Created by Simon Bromberg on 2024-03-12.
//

import SwiftUI

struct GuessingView: View {
  let pokemon: Pokemon

  var body: some View {
    VStack {
      Text("Who's that Pokemon?")
        .font(.title)
        .padding(.top)
      Rectangle()
        .foregroundStyle(Color.black.opacity(1))
        .mask(
          AsyncImage(
            url: (pokemon.images.first).flatMap { .init(string: $0) }
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
        )
        .padding()
    }
  }
}

#Preview {
  GuessingView(pokemon: .test)
}
