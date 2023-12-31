//
//  UserInfoVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AltibbiTelehealth

class UserInfoVC: UIViewController {

    @IBOutlet weak var userIdView: UILabel!
    @IBOutlet weak var userNameView: UILabel!
    @IBOutlet weak var userGenderView: UILabel!
    @IBOutlet weak var userInsuranceView: UILabel!
    @IBOutlet weak var userEmailView: UILabel!
    var receivedData: User?
    
    public func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            // Handle the OK button tap (if needed)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = receivedData {
            DispatchQueue.main.async {
                if data.id != nil, let userId = data.id {
                    self.userIdView.text = String(userId)
                }
                if data.name != nil {
                    self.userNameView.text = data.name
                }
                if data.gender != nil {
                    self.userGenderView.text = data.gender
                }
                if data.insuranceId != nil {
                    self.userInsuranceView.text = data.insuranceId
                }
                if data.email != nil {
                    self.userEmailView.text = data.email
                }
            }
        }
    }
}
