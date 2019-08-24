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
        case setInput(String)
        case setPasscode(String)
        case setKeys([String])
        case setValidation(Validation)
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
            return Observable.from([
                Mutation.setInput(""),
                Mutation.setPasscode(generatePasscode()),
                Mutation.setKeys(shuffleKeys()),
                Mutation.setValidation(.normal)
            ])
        case .typing(let key):
            guard let key = key, currentState.validation == .normal else { return .empty() }
            let nextKeys = shuffleKeys()
            switch key {
            case "0"..."9":
                return state.take(1)
                    .map { ($0.input + key, $0.passcode) }
                    .flatMap { (input, passcode) -> Observable<Mutation> in
                        return Observable.from([
                            Mutation.setInput(input),
                            input.count == Constant.maxInput ? (Mutation.setValidation(input == passcode ? .valid : .invalid)) : Mutation.setKeys(nextKeys)
                        ])
                    }
            case "<":
                return state.take(1)
                    .map { $0.input }
                    .filter { $0.count > 0 }
                    .flatMap { input -> Observable<Mutation> in
                        return Observable.from([
                            Mutation.setInput(String(input.prefix(input.count - 1))),
                            Mutation.setKeys(nextKeys)
                        ])
                    }
            default:
                return .empty()
            }
        }
    }
  
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setInput(let input):
            newState.input = input
        case .setPasscode(let passcode):
            newState.passcode = passcode
        case .setKeys(let keys):
            newState.keys = keys
        case .setValidation(let validation):
            newState.validation = validation
        }
        return newState
  }
  
    func generatePasscode() -> String {
        return String((0 ..< Constant.maxInput).map { _ in Character("\(arc4random() % 10)") })
    }
  
    func shuffleKeys() -> [String] {
        let keys = (0...9).map { "\($0)" } + ["<"]
        return keys.shuffled()
    }
}
