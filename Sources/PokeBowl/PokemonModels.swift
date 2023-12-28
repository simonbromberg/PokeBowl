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
  let evolutions: [Species]
}

struct Pokemon: Identifiable, Hashable {
  let name: String
  let id: Int
  let imageURL: URL
  let types: [PokemonType]

  internal init(id: Int, name: String, imageURL: URL, types: [PokemonType]) {
    self.id = id
    self.name = name
    self.imageURL = imageURL
    self.types = types
  }
}
