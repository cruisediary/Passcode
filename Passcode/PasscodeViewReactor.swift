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
  enum Action {
    case generate
  }
  
  enum Mutation {
    case generatePasscode
  }
  
  struct State {
    var passcode: String
  }
  
  let initialState = State(passcode: "0000")
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .generate:
      return Observable.just(Mutation.generatePasscode)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .generatePasscode:
      let newPasscode = String((0...3).map { _ in Character("\(arc4random() % 10)") })
      return State(passcode: newPasscode)
    }
  }
}
