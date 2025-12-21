//
//  HomeVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import AltibbiTelehealth

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openConsultationScreen(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "consultationsSegue", sender: nil)
        }
    }
    @IBAction func openPhrsScreen(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "phrsSegue", sender: nil)
        }
    }

}
