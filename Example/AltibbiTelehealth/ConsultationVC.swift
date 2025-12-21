//
//  ConsultationVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import AltibbiTelehealth
import MobileCoreServices


class ConsultationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var questionField: UITextView!
    @IBOutlet weak var chatOption: UIButton!
    @IBOutlet weak var gsmOption: UIButton!
    @IBOutlet weak var videoOption: UIButton!
    @IBOutlet weak var voipOption: UIButton!
    var medium = ""
    @IBOutlet weak var userIdField: UITextField!
    var mediaIds: [String] = []
    @IBOutlet weak var deleteIdField: UITextField!
    @IBOutlet weak var viewIdField: UITextField!
    @IBOutlet weak var prescriptionIdField: UITextField!
    @IBOutlet weak var listFilterField: UITextField!

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
        questionField.layer.borderColor = UIColor.gray.cgColor
        questionField.layer.borderWidth = 1.0
        questionField.layer.cornerRadius = 5.0
    }

    func showFilePicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }

        print("File Extension: \(fileURL.pathExtension)")
        if fileURL.pathExtension.lowercased() == "pdf" {
            print("File Selected: PDF")
            do {
                let pdfData = try Data(contentsOf: fileURL)
                handleFileUpload(data: pdfData, type: "pdf")
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Convert PDF" , message: "\(error)")
                }
                print("Error converting PDF to Data: \(error)")
            }
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "PDF" , message: "Selected File is Not PDF")
            }
            print("File Selected: Not PDF")
        }
    }

    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // Use .camera for camera access

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let pickedImage = info[.originalImage] as? UIImage {
            print("Image: \(String(describing: pickedImage))")
            if let imageData = pickedImage.jpegData(compressionQuality: 0.5) {
                handleFileUpload(data: imageData, type: "img")
            }
        }
    }

    func handleFileUpload(data: Data, type: String) -> Void {
        ApiService.uploadMedia(jsonFile: data, type: type, completion: {media, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                if let media = media {
                    self.mediaIds.append(media.id!)
                    DispatchQueue.main.async {
                        self.showAlert(title: "Upload", message: "File Uploaded Successfully")
                    }
                    print("Media IDs: \(String(describing: self.mediaIds))")
                }
            }
        })
    }

    @IBAction func mediumOptionSelected(_ sender: UIButton?) {
        chatOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        gsmOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        videoOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        voipOption.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        medium = ""
        if sender != nil {
            sender!.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            let mediumLabel = sender!.titleLabel?.text?.lowercased()
            medium = mediumLabel!.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Medium Selected: \(mediumLabel!)")
        }
    }
    @IBAction func addFileClicked(_ sender: UIButton) {
        if sender.titleLabel!.text == "Add PDF" {
            showFilePicker()
        } else {
            showImagePicker()
        }
    }
    @IBAction func createConsultation(_ sender: Any) {
        let questionBody = questionField.text
        let userId = userIdField.text
        if questionBody!.count == 0 {
            questionField.layer.borderColor = UIColor.red.cgColor
            questionField.layer.borderWidth = 1.0
            questionField.layer.cornerRadius = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.questionField.layer.borderColor = UIColor.gray.cgColor
                self.questionField.layer.borderWidth = 1.0
                self.questionField.layer.cornerRadius = 5.0
            }
            return
        }
        if questionBody!.count < 11 {
            self.showAlert(title: "Question Body", message: "Should be more than 11")
            return
        }
        if medium.count == 0 {
            self.showAlert(title: "Consultation Medium", message: "Select Medium")
            return
        }
        if userId!.count == 0 {
            self.showAlert(title: "User ID", message: "Insert User ID")
            return
        }
        if let intId = Int(userId!) {
            let consultation = Consultation(userId: intId, question: questionBody!, medium: medium, mediaIds: mediaIds)//parentConsultationId: 123 in case user asked to followup on previous consultation

            //ApiService.createConsultation(consultation: consultation,forceWhiteLabelingPartnerName: "YourcompanyName" // in case partner needed doctors to white label themselved from their company
            ApiService.createConsultation(consultation: consultation, completion: {createdConsultation, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if let consultation = createdConsultation {
                        DispatchQueue.main.async {
                            self.questionField.text = ""
                            self.mediaIds = []
                            self.userIdField.text = ""
                            self.mediumOptionSelected(nil)
                            self.performSegue(withIdentifier: "waitingConsultationSegue", sender: consultation)
                        }
                    }
                }
            })

        } else {
            self.showAlert(title: "User ID", message: "Insert Valid User ID")
        }
    }
    @IBAction func deleteClicked(_ sender: Any) {
        if let deleteId = deleteIdField.text, deleteId.count > 0, let intId = Int(deleteId) {
            ApiService.deleteConsultation(id: intId, completion: {success, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if success != nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Consultation With ID \(deleteId) Deleted Successfully")
                        }
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "Consultation ID", message: "Insert a Valid ID")
            }
        }
    }

    @IBAction func cancelClicked(_ sender: Any) {
        if let deleteId = deleteIdField.text, deleteId.count > 0, let intId = Int(deleteId) {
            ApiService.cancelConsultation(id: intId, completion: {cancelledConsultation, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if cancelledConsultation != nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Consultation With ID \(deleteId) Cancelled Successfully")
                        }
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "Consultation ID", message: "Insert a Valid ID")
            }
        }
    }
    @IBAction func getConsultationClicked(_ sender: Any) {
        if let viewId = viewIdField.text, viewId.count > 0, let intId = Int(viewId) {
            ApiService.getConsultationInfo(id: intId, completion: {consultation, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if let consultation = consultation {
                        print("Consultation Info: \(String(describing: consultation))")
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "Consultation ID", message: "Insert a Valid ID")
            }
        }
    }
    @IBAction func getListClicked(_ sender: Any) {
        var filterId: Int? = nil
        if let id = self.listFilterField.text, id.count > 0, let intId = Int(id) {
            filterId = intId
        }
        ApiService.getConsultationList(userId: filterId, page: 1, perPage: 20, completion: {list, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                print("Consultation Count: \(String(describing: list?.count))")
                if let list = list {
                    for cons in list {
                        print("Consultation ID: \(String(describing: cons.consultationId)), Question: \(String(describing: cons.question)), User ID: \(String(describing: cons.userId))")
                    }
                }
            }
        })
    }
    @IBAction func getLastClicked(_ sender: Any) {
        ApiService.getLastConsultation(completion: {consultation, failure, error in
            if let error = error {
                print("Data Error: \(String(describing: error))")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                if let consultation = consultation {
                    print("Last Consultation: \(String(describing: consultation))")
                    if consultation.status == "in_progress" {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "waitingConsultationSegue", sender: consultation)
                        }
                    }
                }
            }
        })
    }
    @IBAction func getPrescriptionClicked(_ sender: Any) {
        if let consId = prescriptionIdField.text, consId.count > 0, let intId = Int(consId) {
            ApiService.getPrescription(id: intId, completion: {pathUrl, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    if pathUrl != nil {
                        print("Success: \(String(describing: pathUrl))")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "viewPrescriptionSegue", sender: pathUrl)
                        }
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "Consultation ID", message: "Insert a Valid ID")
            }
        }
    }
    @IBAction func closeChat(_ sender: Any) {
        AltibbiChat.disconnectChat()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "waitingConsultationSegue" {
            if let destVc = segue.destination as? WaitingVC {
                if let data = sender as? Consultation {
                    destVc.consultationInfo = data
                }
            }
        }
        if segue.identifier == "viewPrescriptionSegue" {
            if let destVc = segue.destination as? PrescriptionVC {
                if let data = sender as? URL {
                    destVc.receivedData = data
                }
            }
        }
    }


    func attachAsCSV(jsonData: [[String: String]]) {
        do {
            let fileName = "attach-consultation-\(Int(Date().timeIntervalSince1970)).csv"
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            var csvContent = ""

            if let headers = jsonData.first?.keys {
                csvContent.append(headers.joined(separator: ",") + "\n")

                for row in jsonData {
                    let rowValues = row.values.joined(separator: ",")
                    csvContent.append(rowValues + "\n")
                }
            }

            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

            if let csvData = try? Data(contentsOf: fileURL) {
                ApiService.uploadMedia(jsonFile: csvData, type: "text/csv", completion: { media, failure, error in
                    if let error = error {
                        print("Data Error: \(String(describing: error))")
                    } else if let failure = failure {
                        ResponseFailure.printJsonData(failure)
                    } else if let media = media {
                        DispatchQueue.main.async {
                            self.mediaIds.append(media.id!)
                        }
                        print("Media IDs: \(String(describing: self.mediaIds))")
                    }
                })
            }
        } catch let error {
            print("Error writing or uploading CSV file: \(error.localizedDescription)")
        }
    }
}
