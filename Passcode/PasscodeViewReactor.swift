//
//  PasscodeReactor.swift
//  Passcode
//
//  Created by CruzDiary on 19/05/2017.
//  Copyright © 2017 Cruz. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

extension MutableCollection where Indices.Iterator.Element == Index {
  /// Shuffles the contents of this collection.
  mutating func shuffle() {
    let c = count
    guard c > 1 else { return }
    
    for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
      let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
      guard d != 0 else { continue }
      let i = index(firstUnshuffled, offsetBy: d)
      swap(&self[firstUnshuffled], &self[i])
    }
  }
}

extension Sequence {
  /// Returns an array with the contents of this sequence, shuffled.
  func shuffled() -> [Iterator.Element] {
    var result = Array(self)
    result.shuffle()
    return result
  }
}

class PasscodeViewReactor: Reactor {
  enum Action {
    case generate
    case typing(key: String?)
  }
  
  enum Mutation {
    case generatePasscode
    case insert(key: String)
    case delete
  }
  
  struct State {
    var passcode: String
    var input: String
    var keys: [String]
  }
  
  let initialState = State(passcode: "0000", input: "", keys: (0...9).map { "\($0)" } + ["<"])
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .generate:
      return Observable.just(Mutation.generatePasscode)
    case .typing(let key):
      guard let key = key else {
        return Observable.empty()
      }
      switch key {
        case "0"..."9":
          return Observable.just(Mutation.insert(key: key))
        case "<":
          return Observable.just(Mutation.delete)
        default:
          return Observable.empty()
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .generatePasscode:
      var newState = state
      newState.passcode = generatePasscode()
      newState.keys = shuffleKeys()
      return newState
    case .insert(let key):
      var newState = state
      newState.input = state.input + key
      newState.keys = shuffleKeys()
      return newState
    case .delete:
      var newState = state
      newState.input.characters.popLast()
      newState.keys = shuffleKeys()
      return newState
    }
  }
  
  func generatePasscode() -> String {
    return String((0...3).map { _ in Character("\(arc4random() % 10)") })
  }
  
  func shuffleKeys() -> [String] {
    let keys = (0...9).map { "\($0)" } + ["<"]
    return keys.shuffled()
  }
}
