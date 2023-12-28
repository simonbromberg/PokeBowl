//
//  Networking.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-11-28.
//

import Foundation

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

  func loadPokemon(_ id: Int) async throws -> Species {
    let speciesResponse = try await getSpecies("\(baseURLString)pokemon-species/\(id)")
    let varieties = try await speciesResponse.varieties.map {
      let response = try await getPokemon($0.pokemon.url)
      return Pokemon(response)
    }

    let evolution = try await getEvolutionChain(speciesResponse.evolutionChain.url)
    var evolutions = try await evolution.chain.evolvesTo.map {
      try await expandEvolution($0)
    }
    
    let evolutionBaseSpecies = try await getSpecies(evolution.chain.species.url)
    if evolutionBaseSpecies.name != speciesResponse.name {
      let baseSpeciesVarieties = try await evolutionBaseSpecies.varieties.map {
        let response = try await getPokemon($0.pokemon.url)
        return Pokemon(response)
      }
      evolutions.insert(
        .init(
          id: evolutionBaseSpecies.id,
          name: evolutionBaseSpecies.name,
          varieties: baseSpeciesVarieties,
          evolutions: evolutions
        ),
        at: 0
      )
    }

    return .init(
      id: speciesResponse.id,
      name: speciesResponse.name,
      varieties: varieties,
      evolutions: evolutions
    )
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

  private func expandEvolution(_ evolution: EvolutionChain.ChainLink) async throws -> Species {
    let species = try await getSpecies(evolution.species.url)
    let varieties = try await species.varieties.map {
      let response = try await getPokemon($0.pokemon.url)
      return Pokemon(response)
    }
    
    let evolutions = try await evolution.evolvesTo.map {
      try await expandEvolution($0)
    }

    return .init(
      id: species.id,
      name: species.name,
      varieties: varieties,
      evolutions: evolutions
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

private extension Pokemon {
  init(_ response: PokemonResponse) {
    self.init(
      id: response.id,
      name: response.name,
      images: [
        response.sprites.other.officialArtwork.frontDefault,
        response.sprites.other.officialArtwork.frontShiny
      ].compactMap { $0 },
      types: response.types
    )
  }
}
