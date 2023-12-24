//
//  Networking.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import Foundation

struct Networking {
  let baseURL: URL

  static var shared: Self = Networking(
    baseURL: .init(string: "https://pokeapi.co/api/v2/pokemon/")!
  )

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func loadPokemon(_ id: Int) async throws -> Pokemon {
    let (data, _) = try await URLSession.shared.data(from: baseURL.appending(path: "\(id)"))
    let response = try decoder.decode(PokemonResponse.self, from: data)

    let species = try await getSpecies(response.species.url)
    let evolution = try await getEvolutionChain(species.evolutionChain.url)
    let evolutions = try await evolution.chain.evolvesTo.map {
      let speciesLink = $0.species
      let species = try await getSpecies(speciesLink.url)
      let varieties = species.varieties
      return try await varieties.map {
        try await decoder.decode(PokemonResponse.self, from: getData($0.pokemon.url))
      }
    }.flatMap { $0 }


    return .init(
      response,
      evolutions: evolutions
    )
  }

  private func getSpecies(_ urlString: String) async throws -> PokemonSpecies {
    try await decoder.decode(PokemonSpecies.self, from: getData(urlString))
  }

  private func getEvolutionChain(_ urlString: String) async throws -> EvolutionChain {
    try await decoder.decode(EvolutionChain.self, from: getData(urlString))
  }

  // MARK: - Helpers

  private func getData(_ urlString: String) async throws -> Data {
    let url = try URL(string: urlString).unwrap()
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
  }
}

struct Pokemon: Identifiable, Hashable {
  let name: String
  let evolutions: [Pokemon]
  let id: Int
  let imageURL: URL
  let types: [PokemonType]

  internal init(id: Int, name: String, evolutions: [Pokemon], imageURL: URL, types: [PokemonType]) {
    self.id = id
    self.name = name
    self.evolutions = evolutions
    self.imageURL = imageURL
    self.types = types
  }

  fileprivate init(_ response: PokemonResponse, evolutions: [PokemonResponse] = []) {
    self.init(
      id: response.id,
      name: response.name,
      evolutions: evolutions.map { .init($0) },
      imageURL: .init(
        string: response.sprites.other.officialArtwork.frontDefault
      )!,
      types: response.types
    )
  }
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
  let id: Int
  let sprites: Sprites
  let name: String
  let types: [PokemonType]
  let species: NameLink

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

struct PokemonSpecies: Decodable {
  let evolutionChain: Link
  let varieties: [Variety]

  struct Variety: Decodable {
    let isDefault: Bool
    let pokemon: NameLink
  }
}

public struct EvolutionChain: Decodable {
  let id: Int
  let chain: ChainLink

  struct ChainLink: Decodable {
    let species: NameLink
    let evolvesTo: [ChainLink]
  }
}

struct Link: Decodable {
  let url: String
}

struct NameLink: Decodable {
  let name: String
  let url: String
}
