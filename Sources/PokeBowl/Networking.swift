//
//  Networking.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import Foundation

struct Networking {
  let baseURL: URL

  func loadPokemon(_ id: Int) async throws -> Pokemon {
    let (data, _) = try await URLSession.shared.data(from: baseURL.appending(path: "\(id)"))
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let response = try decoder.decode(PokemonResponse.self, from: data)

    return .init(
      name: response.name,
      imageURL: .init(
        string: response.sprites.other.officialArtwork.frontDefault
      )!,
      types: response.types
    )
  }

  func getTotalPokemonCount() async throws -> Int {
    let (data, _) = try await URLSession.shared.data(from: baseURL)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(PokemonCountResponse.self, from: data).count
  }

  func getEvolution() async throws -> Int {
    let (data, _) = try await URLSession.shared.data(from: baseURL)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(PokemonCountResponse.self, from: data).count
  }

  static var shared: Self = Networking(
    baseURL: .init(string: "https://pokeapi.co/api/v2/pokemon/")!
  )
}

struct Pokemon {
  let name: String
  let imageURL: URL
  let types: [PokemonType]
}

struct PokemonType: Decodable, Hashable {
  let slot: Int
  let type: InnerType

  struct InnerType: Decodable, Hashable {
    let name: String
    let url: String
  }
}

private struct PokemonResponse: Decodable {
  let sprites: Sprites
  let name: String
  let types: [PokemonType]

  struct Sprites: Decodable {
    let other: Other

    struct Other: Decodable {
      let officialArtwork: OfficialArtwork

      enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
      }

      struct OfficialArtwork: Decodable {
        let frontDefault: String
        let frontShiny: String
      }
    }
  }
}

private struct PokemonCountResponse: Decodable {
  let count: Int
}

private struct EvolutionChain: Decodable {
  let id: String
  let chain: ChainLink

  struct ChainLink: Decodable {
    let species: String
  }
}
