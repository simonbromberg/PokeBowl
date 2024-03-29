//
//  PokemonMatchingGame.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-31.
//

import AsyncMap
import MatchingGame
import SwiftUI

struct PokemonMatchingGame: View {
  @State private var selectedCount: Double = 20
  @State private var isLoading = false
  @State private var showingSheet = false

  var body: some View {
    VStack {
      Text("\(selectedCount, format: .number) pokemon tiles")
      Slider(
        value: $selectedCount,
        in: 2...100,
        step: 1
      )
      Button("Start ▶️") {
        isLoading = true
        Task {
          do {
            print(selectedCount)
            try await ImageLoader.shared.loadImages(limit: Int(selectedCount))
          } catch {
            print(error)
          }
          isLoading = false
          showingSheet = true
        }
      }
      .fullScreenCover(isPresented: $showingSheet) {
        MatchingContentView(matchables: ImageLoader.shared.images)
      }
      ProgressView()
        .foregroundStyle(Color.black)
        .opacity(isLoading ? 1 : 0)
    }
    .padding()
  }
}

private class ImageLoader {
  var images: [UIImage] = []
  static let shared = ImageLoader()

  func loadImages(limit: Int) async throws {
    let pokemon = try await Networking.shared.loadPokemon(limit: limit)
    print("Loaded pokemon \(pokemon.count)!")

    let images: [UIImage] = try await pokemon.compactMap {
      guard let imageUrlString = $0.images.first else {
        return nil
      }
      let imageData = try await Networking.shared.loadImageData(imageUrlString)
      print("Loaded image!")
      return UIImage(data: imageData)
    }

    self.images = images
  }
}

#Preview {
  PokemonMatchingGame()
}
