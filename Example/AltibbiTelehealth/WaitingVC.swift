//
//  WaitingVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import AltibbiTelehealth

class WaitingVC: UIViewController {

    let decoder = JSONDecoder()
    var consultationInfo: Consultation?
    @IBOutlet weak var idValueLbl: UILabel!
    @IBOutlet weak var progressLLbl: UILabel!
    @IBOutlet weak var consultationInfoBtn: UIButton!

    func onEvent(name: String, data: String?) {
        if let data = data {
            print("Event onEvent >>>>>>>>>> \(name) : \(data)")
            if name == "pusher:subscription_error" {
                DispatchQueue.main.async {
                    self.progressLLbl.text = "Error..."
                }
            } else if name == "pusher:subscription_succeeded" {
                DispatchQueue.main.async {
                    self.progressLLbl.text = "Connected..."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.progressLLbl.text = "Waiting Doctor Accept..."
                }
            } else if data == "accepted" {
                DispatchQueue.main.async {
                    self.progressLLbl.text = "Doctor Accepted..."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.progressLLbl.text = "Doctor Reading Information..."
                }
            } else if data == "in_progress" {
                DispatchQueue.main.async {
                    self.progressLLbl.text = "Starting Consulation Now..."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.progressLLbl.text = "Consulation In Progress..."
                    self.openConsultationScreen()
                }
            }
        }
    }

    func openConsultationScreen() {
        ApiService.getConsultationInfo(id: (consultationInfo?.consultationId)!, completion: {consultation, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                if let consultation = consultation {
                    if (consultation.chatConfig != nil) {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "chatScreenSegue", sender: consultation)
                        }
                    } else if (consultation.videoConfig != nil || consultation.voipConfig != nil) {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "videoScreenSegue", sender: consultation)
                        }
                    }
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let info = consultationInfo {
            DispatchQueue.main.async {
                if info.consultationId != nil {
                    self.idValueLbl.text = String(info.consultationId!)
                }
            }
            if info.status == "in_progress" {
                DispatchQueue.main.async {
                    self.progressLLbl.text = "Consulation In Progress..."
                    self.consultationInfoBtn.titleLabel?.text = "Open Chat Screen"
                }
                openConsultationScreen()
            } else {
                if let appKey = info.socketKey, let channelName = info.socketChannel {
                    print("AppKey: \(appKey), Channel: \(channelName)")
                    TBISocket.initiateSocket(
                        appKey: appKey,
                        channelName: channelName,
                        onEvent: onEvent
                    )

                }
            }
        }
    }
    @IBAction func getInfoClicked(_ sender: Any) {
        if let consId = consultationInfo?.consultationId {
            ApiService.getConsultationInfo(id: consId, completion: {consultation, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if let consultation = consultation {
                        print("Consultation Info: \(String(describing: consultation))")
                        if consultation.status == "in_progress" {
                            if (consultation.chatConfig != nil) {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "chatScreenSegue", sender: consultation)
                                }
                            } else if (consultation.videoConfig != nil || consultation.voipConfig != nil) {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "videoScreenSegue", sender: consultation)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    @IBAction func cancelClicked(_ sender: Any) {
        if let info = consultationInfo {
            ApiService.cancelConsultation(id: Int(info.consultationId!), completion: {cancelledConsultation, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Cancel", message: "Consultation Cancelled Successfuly", goBack: true)
                    }
                    print("Result of cancel consultation \(info.consultationId!) : \(String(describing: cancelledConsultation))")
                }
            })
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatScreenSegue" {
            if let destVc = segue.destination as? ChatConsultationVC {
                if let data = sender as? Consultation {
                    destVc.consultationInfo = data
                }
            }
        }
        if segue.identifier == "videoScreenSegue" {
            if let destVc = segue.destination as? VideoConsultationVC {
                if let data = sender as? Consultation {
                    destVc.consultationInfo = data
                }
            }
        }
    }
}
