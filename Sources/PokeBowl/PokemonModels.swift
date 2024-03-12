//
//  PokemonModels.swift
//  PokeBowl
//
//  Created by Simon Bromberg on 2023-12-27.
//

import Foundation

struct Species: Identifiable, Hashable {
  let id: Int
  let name: String
  let varieties: [Pokemon]
}

struct Evolution: Identifiable {
  var id: Int {
    species.id
  }

  let species: Species
  let evolvesTo: [Evolution]
}

struct Pokemon: Identifiable, Hashable {
  let name: String
  let id: Int
  let images: [String]
  let types: [PokemonType]

  init(id: Int, name: String, images: [String], types: [PokemonType]) {
    self.id = id
    self.name = name
    self.images = images
    self.types = types
  }
}

// TODO: better test models

extension Species {
  static let test: Self = .init(
    id: 1,
    name: "Gorochu",
    varieties: .test
  )
}

extension Pokemon {
  static let test: Self = .init(
    id: 1,
    name: "Foo",
    images: ["https://i.imgur.com/Jek4Pl7.png"],
    types: .test
  )
}

extension Array where Element == Pokemon {
  static let test: Self = [.test]
}

extension Evolution {
  static let test: Self = .init(species: .test, evolvesTo: [])
}

extension Array where Element == PokemonType {
  static let test: Self = [
    .init(
      slot: 0,
      type: .init(
        name: "grass", url: ""
      )
    )
  ]
}
