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

class PasscodeViewReactor: Reactor {
  struct Constant {
    static let maxInput = 4
  }

  enum Action {
    case generate
    case typing(key: String?)
  }
  
  enum Mutation {
    case generatePasscode
    case insert(key: String)
    case delete
  }
  
  enum Validation {
    case normal
    case valid
    case invalid
  }
  
  struct State {
    var passcode: String
    var input: String
    var keys: [String]
    var validation: Validation
  }
  
  let initialState = State(passcode: "0000",
                           input: "",
                           keys: (0...9).map { "\($0)" } + ["<"],
                           validation: .normal)
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .generate:
      return Observable.just(Mutation.generatePasscode)
    case .typing(let key):
      guard let key = key, currentState.validation == .normal else {
        return .empty()
      }
      switch key {
        case "0"..."9":
          return .just(Mutation.insert(key: key))
        case "<":
          return .just(Mutation.delete)
        default:
          return .empty()
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .generatePasscode:
      var newState = state
      newState.input = ""
      newState.passcode = generatePasscode()
      newState.keys = shuffleKeys()
      newState.validation = .normal
      return newState
    case .insert(let key):
      var newState = state
      newState.input = state.input + key
      
      if newState.input.count == Constant.maxInput {
        newState.validation = newState.input == state.passcode ? .valid : .invalid
      } else {
        newState.keys = shuffleKeys()
      }
      
      return newState
    case .delete:
      var newState = state
      _ = newState.input.popLast()
      newState.keys = shuffleKeys()
      return newState
    }
  }
  
  func generatePasscode() -> String {
    return String((0 ..< Constant.maxInput).map { _ in Character("\(arc4random() % 10)") })
  }
  
  func shuffleKeys() -> [String] {
    let keys = (0...9).map { "\($0)" } + ["<"]
    return keys.shuffled()
  }
}
