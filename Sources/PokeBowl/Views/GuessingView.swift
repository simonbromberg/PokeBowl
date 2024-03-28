//
//  GuessingView.swift
//
//
//  Created by Simon Bromberg on 2024-03-12.
//

import SwiftUI

struct GuessingView: View {
  @State private var pokemon: Pokemon?
  @State private var image: UIImage = .init()

  @State private var id: Int = .randomPokemonId() {
    didSet {
      pokemon = nil
      image = .init()
      isMasked = true
      loadPokemon()
    }
  }

  @State private var isMasked = true

  private func loadPokemon() {
    Task {
      do {
        pokemon = try await Networking.shared.loadPokemon(id: id).0.varieties.first.unwrap()
        try await loadImage()
      } catch {
        print("Pokemon id: \(id)")
        print(error)
      }
    }
  }

  private func loadImage() async throws {
    let imageURL = try pokemon.unwrap().images.first.unwrap()
    let imageData = try await Networking.shared.loadImageData(imageURL)
    image = try .init(data: imageData).unwrap()
  }

  var body: some View {
    VStack {
      Text("Who's that Pokemon?")
        .font(.title)
        .padding(.top)
      Text(pokemon?.name.capitalized ?? "")
        .font(.title)
        .bold()
        .redacted(reason: isMasked ? .placeholder : [])
        .padding(.top)
      ZStack {
        Rectangle()
          .foregroundStyle(Color.black.opacity(1))
          .mask(
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fit)
          )
          .opacity(isMasked ? 1 : 0)
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .opacity(isMasked ? 0 : 1)
        ProgressView()
          .opacity(pokemon == nil ? 1 : 0)
      }
      .onTapGesture {
        if !isMasked {
          id = .randomPokemonId()
        } else {
          isMasked = false
        }
      }
      .padding()
    }
    .onAppear {
      loadPokemon()
    }
  }
}

#Preview {
  GuessingView()
}
