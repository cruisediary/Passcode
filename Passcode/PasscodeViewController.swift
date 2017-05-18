//
//  ViewController.swift
//  Passcode
//
//  Created by CruzDiary on 18/05/2017.
//  Copyright © 2017 Cruz. All rights reserved.
//

import UIKit

import GSMessages
import Pastel
import ReactorKit
import RxCocoa
import RxSwift

class PasscodeViewController: UIViewController, View {
  @IBOutlet weak var generateButton: UIButton!
  // Rx
  var disposeBag = DisposeBag()
  
  @IBOutlet weak var pastelView: PastelView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.reactor = PasscodeViewReactor()
    setupPastel()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func setupPastel() {
    // Animation
    pastelView.setColors([#colorLiteral(red: 0.6509803922, green: 0.7568627451, blue: 0.9333333333, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)])
    pastelView.animationDuration = 3.0
    pastelView.startAnimation()
  }
  
  func bind(reactor: PasscodeViewReactor) {
    // Action
    generateButton.rx.tap
      .map { Reactor.Action.generate }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    reactor.state
      .map { $0.passcode }
      .map { "😜 Password changed to \($0)" }
      .subscribe { [weak self](event) in
        guard let s = self, let message = event.element else { return }
        s.showMessage(message, type: .info)
      }.disposed(by: disposeBag)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

