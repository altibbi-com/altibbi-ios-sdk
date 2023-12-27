//
//  CreateUserVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AltibbiTelehealth

class CreateUserVC: UIViewController {
       
    @IBOutlet weak var datePicker: UIDatePicker!
    var dateOfBirth = ""
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var maleGenderOption: UIButton!
    @IBOutlet weak var femaleGenderOption: UIButton!
    var genderOption = ""
    @IBOutlet weak var insuranceField: UITextField!
    @IBOutlet weak var policyNumField: UITextField!
    @IBOutlet weak var nationallityNumField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var bloodTypeField: UITextField!
    var smoker = false
    var alcoholic = false
    @IBOutlet weak var maritalStatusField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        
        // Do any additional setup after loading the view.
    }
    
    public func showAlert(title: String, message: String, goBack: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if goBack {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dateValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        let formattedDate = dateFormatter.string(from: selectedDate)
        dateOfBirth = formattedDate
        print("Selected Date: \(formattedDate)")
    }
    
    @IBAction func genderOptionSelected(_ sender: UIButton) {
        maleGenderOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        femaleGenderOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        sender.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        let senderLabel = sender.titleLabel?.text?.lowercased()
        genderOption = senderLabel!.trimmingCharacters(in: .whitespacesAndNewlines)
        print("Gender Selected: \(senderLabel!)")
    }
    @IBAction func smokerBoxTapped(_ sender: UIButton) {
        if smoker {
            smoker = false
            sender.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            smoker = true
            sender.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
    }
    @IBAction func alcoholOptionTapped(_ sender: UIButton) {
        if alcoholic {
            alcoholic = false
            sender.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            alcoholic = true
            sender.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
    }
    @IBAction func submitBtnClicked(_ sender: Any) {
        let name = nameField.text!
        let email = emailField.text!
        let insurance = insuranceField.text!
        let policyNumber = policyNumField.text!
        let nationalityNumber = nationallityNumField.text!
        let height = Double(heightField.text!)
        let weight = Double(weightField.text!)
        let bloodType = bloodTypeField.text!
        let smokeOption = smoker ? "yes" : "no"
        let alcoholOption = alcoholic ? "yes" : "no"
        let maritalStatus = maritalStatusField.text!
        
        let newUser = User(
            name: name.count > 0 ? name : nil,
            email: email.count > 0 ? email : nil,
            dateOfBirth: dateOfBirth.count > 0 ? dateOfBirth : nil,
            gender: genderOption.count > 0 ? genderOption : nil,
            insuranceId: insurance.count > 0 ? insurance : nil,
            policyNumber: policyNumber.count > 0 ? policyNumber : nil,
            nationalityNumber: nationalityNumber.count > 0 ? nationalityNumber : nil,
            height: height,
            weight: weight,
            bloodType: bloodType.count > 0 ? bloodType : nil,
            smoker: smokeOption,
            alcoholic: alcoholOption,
            maritalStatus: maritalStatus.count > 0 ? maritalStatus : nil
        )
        ApiService.createUser(userData: newUser, completion: {user, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                if let user = user {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success" , message: "User Created Successfully! User ID: \(user.id ?? 0)", goBack: true)
                    }
                }
            }
        })
    }
}
