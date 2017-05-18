//
//  ViewController.swift
//  Passcode
//
//  Created by CruzDiary on 18/05/2017.
//  Copyright © 2017 Cruz. All rights reserved.
//

import UIKit

import Pastel

class PasscodeViewController: UIViewController {

    @IBOutlet weak var pastelView: PastelView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPastel()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupPastel() {
        pastelView.setPastelGradient(.youngPassion)
        pastelView.animationDuration = 1.0
        pastelView.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

