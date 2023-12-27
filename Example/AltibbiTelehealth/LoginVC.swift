//
//  LoginVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import AltibbiTelehealth

class LoginVC: UIViewController {

    @IBOutlet var tokenField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let tokenTxt = tokenField.text {
            let tokenLength = tokenTxt.count
            if tokenLength == 0 {
                errorLbl.text = "Please Insert Token!"
                return
            }
            AltibbiService.initService(token: tokenTxt, baseUrl: "tawuniya.altibb.com", language: "en")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toOptionsSegue", sender: nil)
            }
        }
    }

}
