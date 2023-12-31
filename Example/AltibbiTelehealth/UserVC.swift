//
//  UserVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AltibbiTelehealth

class UserVC: UIViewController {
    
    @IBOutlet weak var userIdGetField: UITextField!
    @IBOutlet weak var userIdDeleteField: UITextField!
    @IBOutlet weak var nameEditField: UITextField!
    @IBOutlet weak var emailEditField: UITextField!
    @IBOutlet weak var heightEditField: UITextField!
    @IBOutlet weak var idEditField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func getUserByIdClicked(_ sender: Any) {
        if let userId = userIdGetField.text {
            if userId.count == 0 {
                userIdGetField.layer.borderColor = UIColor.red.cgColor
                userIdGetField.layer.borderWidth = 1.0
                userIdGetField.layer.cornerRadius = 5.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.userIdGetField.layer.borderColor = UIColor.black.cgColor
                    self.userIdGetField.layer.borderWidth = 0
                }
                return
            }
            print("Getting Info For User ID: \(userId)")
            if let intId = Int(userId) {
                print("Int ID: \(intId)")
                ApiService.getUser(id: intId, completion: {user, failure, error in
                    if let error = error {
                        print("Data Error: \(String(describing: error))")
                    } else if let failure = failure {
                        ResponseFailure.printJsonData(failure)
                    } else {
                        if let user = user {
                            print("Data Response: \(String(describing: user))")
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "userInfoSegue", sender: user)
                            }
                        }
                    }
                })
            } else {
                showAlert(title: "Invalid ID", message: "Please Insert a Valid ID")
                print("Not Valid ID")
            }
        }
    }
    
    @IBAction func showUsersListClicked(_ sender: Any) {
        ApiService.getUsers(page: 1, perPage: 20, completion: {users, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                if let users = users {
                    print("Data Response: \(String(describing: users))")
                    for user in users {
                        print("User: \(String(describing: user.id)), Name: \(String(describing: user.name))")
                    }
                }
            }
        })
    }
    
    @IBAction func deleteUserClicked(_ sender: Any) {
        if let userId = userIdDeleteField.text {
            if userId.count == 0 {
                userIdDeleteField.layer.borderColor = UIColor.red.cgColor
                userIdDeleteField.layer.borderWidth = 1.0
                userIdDeleteField.layer.cornerRadius = 5.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.userIdDeleteField.layer.borderColor = UIColor.black.cgColor
                    self.userIdDeleteField.layer.borderWidth = 0
                }
                return
            }
            print("Deleting User With ID: \(userId)")
            if let intId = Int(userId) {
                print("Int ID: \(intId)")
                ApiService.deleteUser(id: intId, completion: {data, failure, error in
                    if let error = error {
                        print("Data Error: \(String(describing: error))")
                    } else if let failure = failure {
                        ResponseFailure.printJsonData(failure)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Delete User", message: "Deleted Successfuly")
                        }
                        print("Result of deleting User \(intId) : \(String(describing: data))")
                    }
                })
            } else {
                showAlert(title: "Invalid ID", message: "Please Insert a Valid ID")
                print("Not Valid ID")
            }
        }
    }
    
    @IBAction func updateUserClicked(_ sender: Any) {
        if let userId = idEditField.text, let name = nameEditField.text, let email = emailEditField.text, let height = heightEditField.text {
            if userId.count == 0 {
                idEditField.layer.borderColor = UIColor.red.cgColor
                idEditField.layer.borderWidth = 1.0
                idEditField.layer.cornerRadius = 5.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.idEditField.layer.borderColor = UIColor.black.cgColor
                    self.idEditField.layer.borderWidth = 0
                }
                return
            }
            if name.count == 0 && email.count == 0 && height.count == 0 {
                self.showAlert(title: "Name/Email/Height", message: "Please Fill One Field At Least")
                return
            }
            if let intId = Int(userId) {
                print("Int ID: \(intId)")
                var newUser = User(id: intId);
                if name.count > 0 {
                    newUser.name = name
                }
                if email.count > 0 {
                    newUser.email = email
                }
                if height.count > 0 {
                    if let doubleHeight = Double(height) {
                        newUser.height = doubleHeight
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Height" , message: "Please Insert a Valid Value For Height")
                            return
                        }
                    }
                }
                ApiService.updateUser(id: intId, userData: newUser, completion: {updatedUser, failure, error in
                    if let error = error {
                        print("Data Error: \(String(describing: error))")
                    } else if let failure = failure {
                        ResponseFailure.printJsonData(failure)
                    } else {
                        if let user = updatedUser {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "userInfoSegue", sender: user)
                            }
                        }
                    }
                })
            } else {
                showAlert(title: "Invalid ID", message: "Please Insert a Valid ID")
            }
        }
    }
    
    @IBAction func createUserClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "userCreationSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfoSegue" {
            if let destVc = segue.destination as? UserInfoVC {
                if let data = sender as? User {
                    destVc.receivedData = data
                }
            }
        }
    }

}
