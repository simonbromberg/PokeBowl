//
//  Networking.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import AsyncMap
import Foundation
import OptionalUnwrap

struct Networking {
  let baseURLString: String

  static var shared: Self = Networking(
    baseURLString: "https://pokeapi.co/api/v2/"
  )

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func loadPokemon(id: Int) async throws -> (Species, Evolution) {
    let speciesResponse = try await getSpecies("\(baseURLString)pokemon-species/\(id)")
    let varieties = try await speciesResponse.varieties.map {
      let response = try await getPokemon($0.pokemon.url)
      return Pokemon(response)
    }

    let chain = try await getEvolutionChain(speciesResponse.evolutionChain.url).chain
    let evolutionBaseSpecies = try await getSpecies(chain.species.url)

    let baseSpeciesVarieties = try await evolutionBaseSpecies.varieties.map {
      let response = try await getPokemon($0.pokemon.url)
      return Pokemon(response)
    }

    let evolutionBase = Species(
      id: evolutionBaseSpecies.id,
      name: evolutionBaseSpecies.name,
      varieties: baseSpeciesVarieties
    )

    let evolutions = try await chain.evolvesTo.map {
      try await expandEvolution($0)
    }

    let species = Species(
      id: speciesResponse.id,
      name: speciesResponse.name,
      varieties: varieties
    )

    let evolution = Evolution(
      species: evolutionBase,
      evolvesTo: evolutions
    )

    return (species, evolution)
  }

  func loadPokemon(limit: Int) async throws -> [Pokemon] {
    struct Response: Decodable {
      let count: Int
      let results: [NameLink]
    }

    let results = try await decoder.decode(
      Response.self,
      from: getData(
        "\(baseURLString)pokemon/?offset=0&limit=1025"
      )
    )
    .results
    .shuffled()
    .prefix(limit)

    return try await results.map {
      let pokemon = try await decoder.decode(PokemonResponse.self, from: getData($0.url))
      return .init(pokemon)
    }
  }

  func loadImageData(_ url: String) async throws -> Data {
    try await getData(url)
  }

  private func getSpecies(_ urlString: String) async throws -> PokemonSpecies {
    try await decoder.decode(PokemonSpecies.self, from: getData(urlString))
  }

  private func getEvolutionChain(_ urlString: String) async throws -> EvolutionChain {
    try await decoder.decode(EvolutionChain.self, from: getData(urlString))
  }

  private func getPokemon(_ urlString: String) async throws -> PokemonResponse {
    try await decoder.decode(PokemonResponse.self, from: getData(urlString))
  }

  private func expandEvolution(_ evolution: EvolutionChain.ChainLink) async throws -> Evolution {
    let species = try await getSpecies(evolution.species.url)
    let varieties = try await species.varieties.map {
      let response = try await getPokemon($0.pokemon.url)
      return Pokemon(response)
    }

    let evolutions = try await evolution.evolvesTo.map {
      try await expandEvolution($0)
    }

    return .init(
      species: .init(id: species.id, name: species.name, varieties: varieties),
      evolvesTo: evolutions
    )
  }

  // MARK: - Helpers

  private func getData(_ urlString: String) async throws -> Data {
    let url = try URL(string: urlString).unwrap()
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
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
        let frontShiny: String?
      }
    }
  }
}

struct PokemonSpecies: Decodable {
  let id: Int
  let name: String
  let evolutionChain: Link
  let varieties: [Variety]

  struct Variety: Decodable {
    let isDefault: Bool
    let pokemon: NameLink
  }
}

struct EvolutionChain: Decodable {
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

private extension Pokemon {
  init(_ response: PokemonResponse) {
    self.init(
      id: response.id,
      name: response.name,
      images: [
        response.sprites.other.officialArtwork.frontDefault,
        response.sprites.other.officialArtwork.frontShiny,
      ].compactMap { $0 },
      types: response.types
    )
  }
}
