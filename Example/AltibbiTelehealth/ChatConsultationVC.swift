//
//  ChatConsultationVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AltibbiTelehealth
import SendbirdChatSDK
import MobileCoreServices

class ChatConsultationVC: UIViewController, GroupChannelDelegate, ConnectionDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    var consultationInfo: Consultation?
    var messages: [BaseMessage] = []
    var query: PreviousMessageListQuery?

    @IBOutlet weak var doctorAvatar: UIImageView!
    @IBOutlet weak var doctorNameLbl: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageBox: UIView!
    @IBOutlet weak var addFilesBtn: UIButton!
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgField: UITextField!
    @IBOutlet weak var typingLbl: UILabel!


    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        if message.sender?.userId == (consultationInfo?.chatConfig?.chatUserId)! {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.configure(with: message)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.configure(with: message)

            return cell
        }
    }

    func scrollToBottom() {
        DispatchQueue.main.async {
            if self.messages.count > 0 {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // MARK: Connection Delegate
    func didDisconnect(userId: String) {
        print("ConnectionDelegate >>> didDisconnect user id: \(userId)")
    }

    // MARK: Groupe Channel Delegate
    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        print("GroupChannelDelegate didReceive >>> Message : \(message.message)")
        DispatchQueue.main.async {
            self.messages += [message]
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    func channel(_ channel: GroupChannel, userDidLeave user: SendbirdChatSDK.User) {
        print("GroupChannelDelegate userDidLeave >>> User \(user.id)")
        DispatchQueue.main.async {
            self.msgField.isEnabled = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.closeConsultation()
        }
    }

    func channelDidUpdateTypingStatus(_ channel: GroupChannel) {
        print("GroupChannelDelegate channelDidUpdateTypingStatus >>> isTyping: \(channel.isTyping())")
        DispatchQueue.main.async {
            if channel.isTyping() {
                self.typingLbl.text = "Typing..."
            } else {
                self.typingLbl.text = ""
            }
        }
    }

    // MARK: Handle Back Press
    @objc private func backButtonPressed() {
        // Intercept the back action
        showCancelAlert(title: "End Consultation", message: "Are You Sure You Want To Cancel?")
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Register Chat Cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        // MARK: File messages could be handled by checking if the message is a link then a new custom cell is needed
        // tableView.register(UINib(nibName: "FileMessageCell", bundle: nil), forCellReuseIdentifier: "FileMessageCell")
        tableView.reloadData()

        // MARK: UI Customization
        DispatchQueue.main.async {
            self.typingLbl.text = ""
        }
        doctorAvatar.contentMode = .scaleAspectFit
        doctorAvatar.layer.cornerRadius = doctorAvatar.frame.size.width / 2
        doctorAvatar.clipsToBounds = true

        separatorView.layer.cornerRadius = 3
        separatorView.clipsToBounds = true

        messageBox.layer.cornerRadius = 6
        messageBox.clipsToBounds = true

        addFilesBtn.layer.cornerRadius = 6
        addFilesBtn.clipsToBounds = true

        sendMsgBtn.layer.cornerRadius = 6
        sendMsgBtn.clipsToBounds = true

        // MARK: Add Back Button
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        navigationItem.leftBarButtonItem = backButton

        // MARK: Chat Initialization
        if let info = consultationInfo, let config = info.chatConfig {
            DispatchQueue.main.async {
                if info.doctorName != nil {
                    self.doctorNameLbl.text = info.doctorName
                }
                // MARK: To View The Avatar For The Doctor, You Can Use SDWebImage
                // if info.doctorAvatar != nil {
                //     if let url = URL(string: info.doctorAvatar!) {
                //         self.doctorAvatar.sd_setImage(with: url, completed: nil)
                //     }
                // }
            }

            AltibbiChat.initialize(config: info.chatConfig!)

            // MARK: Load Previous Messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

                self.query = AltibbiChat.chatChannel!.createPreviousMessageListQuery { params in
                    params.limit = 100
                    params.reverse = false
                }
                print("Start Loading Messages >>> self.query, \(String(describing: self.query))")

                self.query!.loadNextPage(completionHandler: { messages, error in
                    guard error == nil else {
                        print("query?.loadNextPage ERROR, \(error!.localizedDescription)")
                        return
                    }

                    print("query?.loadNextPage messages, \(String(describing: messages))")
                    if let oldMessages = messages {
                        DispatchQueue.main.async {
                            self.messages += oldMessages
                            self.tableView.reloadData()
                            self.scrollToBottom()
                            SendbirdChat.addChannelDelegate(self, identifier: "Channel_Delegate_\(config.groupId ?? "123123")")
                            SendbirdChat.addConnectionDelegate(self, identifier: "Connection_Delegate_\(config.groupId ?? "123123")")
                        }
                    }
                })


            }
        }

    }

    // MARK: Send Message Button Handler
    @IBAction func sendMsgClickedd(_ sender: Any) {
        if let message = msgField.text, message.count > 0 {
            self.sendMessage(msg: message)
        }
    }

    func sendMessage(msg: String) {
        print("Message to send >> \(msg)")
        AltibbiChat.chatChannel!.sendUserMessage(msg, completionHandler: {userMsg, error in
            if error != nil {
                print("sendUserMessage ERROR >>> \(error!.localizedDescription)")
            }
            print("sendUserMessage DONE >>> userMsg: \(String(describing: userMsg))")
            if let sentMessage: BaseMessage = userMsg {
                DispatchQueue.main.async {
                    self.messages += [sentMessage]
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    self.msgField.text = ""
                }

            }
        })
    }

    // MARK: Send File Functions
    @IBAction func addFilesClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.showUploadTypeAlert()
        }
    }

    func showUploadTypeAlert() {
        let alertController = UIAlertController(title: "Upload", message: "Select Upload Type", preferredStyle: .alert)
        let fileAction = UIAlertAction(title: "PDF File", style: .default) { (_) in
            self.showFilePicker()
        }
        let imgAction = UIAlertAction(title: "Image", style: .default) { (_) in
            self.showImagePicker()
        }

        alertController.addAction(fileAction)
        alertController.addAction(imgAction)

        present(alertController, animated: true, completion: nil)
    }

    func showFilePicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            print("Document Picker, No File")
            return
        }

        if fileURL.pathExtension.lowercased() == "pdf" {
            print("File Selected: PDF")
            do {
                let pdfData = try Data(contentsOf: fileURL)
                handleFileUpload(data: pdfData, type: "pdf")
            } catch {
                print("Error converting PDF to Data: \(error)")
            }
        } else {
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
                    self.sendMessage(msg: media.url!)
                }
            }
        })
    }

    // MARK: Close Consultation Alert
    public func showCancelAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            ApiService.cancelConsultation(id: (self.consultationInfo?.consultationId)!, completion: {cancelled, failure, error in
                if let error = error {
                    print("Data Error: \(String(describing: error))")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                    DispatchQueue.main.async {
                        self.closeConsultation()
                    }
                } else {
                    if cancelled != nil {
                        self.closeConsultation()
                    }
                }
            })
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }

    func closeConsultation() {
        DispatchQueue.main.async {
            AltibbiChat.disconnectChat()
            if let navigationController = self.navigationController {
                if let viewControllerToPopTo = navigationController.viewControllers.first(where: { $0 is ConsultationVC }) {
                    navigationController.popToViewController(viewControllerToPopTo, animated: true)
                }
            }
        }
    }

}
