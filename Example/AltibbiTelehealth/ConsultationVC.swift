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
    private var selectedFollowUpConsultationId: Int?
    private var selectedFollowUpShift: String?

    public func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: Date())
    }

    private func shiftValue(from shift: ConsultationAvailableShift) -> String? {
        if let value = normalizedScheduledTo(shift.fullDate) {
            return value
        }
        if let value = normalizedScheduledTo(shift.startAt) {
            return value
        }
        if let value = normalizedScheduledTo(shift.startsAt) {
            return value
        }
        if let value = normalizedScheduledTo(shift.value) {
            return value
        }
        if let value = normalizedScheduledTo(shift.from) {
            return value
        }
        return nil
    }

    private func normalizedScheduledTo(_ rawValue: String?) -> String? {
        guard let rawValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !rawValue.isEmpty else {
            return nil
        }

        if rawValue.contains("-") && rawValue.contains(":") {
            return rawValue
        }

        if let hour = Int(rawValue), hour >= 0, hour <= 23 {
            return String(format: "%@ %02d:00:00", todayDateString(), hour)
        }
        let parts = rawValue.split(separator: ":").map(String.init)
        if parts.count == 2,
           let hour = Int(parts[0]), let minute = Int(parts[1]),
           hour >= 0, hour <= 23, minute >= 0, minute <= 59 {
            return String(format: "%@ %02d:%02d:00", todayDateString(), hour, minute)
        }

        return rawValue
    }

    private func shiftDisplayText(_ shift: ConsultationAvailableShift) -> String {
        let fromValue = shift.from ?? shift.startAt ?? shift.startsAt ?? shift.value ?? "-"
        let toValue = shift.to ?? shift.endAt ?? shift.endsAt
        if let toValue = toValue, !toValue.isEmpty {
            return "\(fromValue) -> \(toValue)"
        }
        return fromValue
    }

    private func presentShiftPicker(consultationId: Int, shifts: [ConsultationAvailableShift]) {
        let alert = UIAlertController(
            title: "Available Shifts",
            message: "Choose a shift to create a follow-up consultation.",
            preferredStyle: .actionSheet
        )

        for shift in shifts {
            let title = shiftDisplayText(shift)
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.selectedFollowUpConsultationId = consultationId
                self.selectedFollowUpShift = self.shiftValue(from: shift)
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Shift Selected",
                        message: "Follow-up will be created for consultation #\(consultationId) at \(self.selectedFollowUpShift ?? title)."
                    )
                }
            }))
        }

        alert.addAction(UIAlertAction(title: "Clear Follow-Up Selection", style: .destructive, handler: { _ in
            self.selectedFollowUpConsultationId = nil
            self.selectedFollowUpShift = nil
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY - 1, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questionField.layer.borderColor = UIColor.gray.cgColor
        questionField.layer.borderWidth = 1.0
        questionField.layer.cornerRadius = 5.0
        questionField.isScrollEnabled = false

        if let scrollView = view as? UIScrollView {
            scrollView.isScrollEnabled = true
            scrollView.alwaysBounceVertical = true
            scrollView.keyboardDismissMode = .onDrag
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollContentSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollContentSize()
    }

    private func updateScrollContentSize() {
        guard let scrollView = view as? UIScrollView else { return }
        scrollView.layoutIfNeeded()

        let contentHeight = scrollView.subviews
            .map { $0.frame.maxY }
            .max() ?? scrollView.bounds.height
        let bottomPadding: CGFloat = 32
        let finalHeight = max(contentHeight + bottomPadding, scrollView.bounds.height + 1)
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: finalHeight)
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
        imagePicker.sourceType = .photoLibrary

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
            let consultation = Consultation(
                userId: intId,
                question: questionBody!,
                medium: medium,
                mediaIds: mediaIds,
                scheduledTo: selectedFollowUpShift,
                parentConsultationId: selectedFollowUpConsultationId
            )
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
                            self.selectedFollowUpConsultationId = nil
                            self.selectedFollowUpShift = nil
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
    @IBAction func getShiftsClicked(_ sender: Any) {
        if let viewId = viewIdField.text, viewId.count > 0, let intId = Int(viewId) {
            let date = "2026-03-25"
            ApiService.getConsultationAvailableShifts(id: intId, date: date, completion: {availableShifts, failure, error in
                if let error = error {
                    print("Available Shifts Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    let shifts = availableShifts?.shifts ?? []
                    print("Available shifts on \(date): \(shifts.count)")
                    for shift in shifts {
                        print("Shift value: \(shift.value ?? "-"), from: \(shift.from ?? shift.startAt ?? shift.startsAt ?? "-"), to: \(shift.to ?? shift.endAt ?? shift.endsAt ?? "-")")
                    }
                    if shifts.count > 0 {
                        self.presentShiftPicker(consultationId: intId, shifts: shifts)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Available Shifts", message: "No shifts available for this date.")
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
