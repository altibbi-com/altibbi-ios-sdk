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

class ChatConsultationVC: UIViewController, GroupChannelDelegate, ConnectionDelegate, UserEventDelegate {
    
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
    
    
    func channelDidUpdateTypingStatus(_ channel: SendbirdChatSDK.GroupChannel) {
        print("ConnectionDelegate >>> isTyping \(channel.isTyping())")
    }
    
    
    func channel(_ channel: SendbirdChatSDK.GroupChannel, userDidLeave user: SendbirdChatSDK.User) {
        if (consultationInfo?.chatConfig?.chatUserId == user.userId) {
            print("left=> Current User => has left the channel: \(channel.name)")
        }
        print("left=> User \(user.userId) has left the channel: \(channel.name)")
    }


    // MARK: Connection Delegate
    func didDisconnect(userId: String) {
        print("ConnectionDelegate >>> didDisconnect user id: \(userId)")
    }
    
    // MARK: Groupe Channel Delegate
    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        print("GroupChannelDelegate >>> Message : \(message.message)")
        self.messages += [message]
    }
    
    // MARK: Handle Back Press
    @objc private func backButtonPressed() {
        // Intercept the back action
        print("backButtonPressed >>>")
        showCancelAlert(title: "End Consultation", message: "Are You Sure You Want To Cancel?")
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: UI Customization
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
                    params.limit = 20
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
                        //self.messages += oldMessages
                        
                        for message in oldMessages {
                            print("Loaded Message >>> Message ID: \(message.messageId), Text: \(message.message)")
                        }
                    }
                })
                
                
            }
            
            SendbirdChat.addChannelDelegate(self, identifier: "Channel_Delegate_\(config.groupId ?? "123123")")
            SendbirdChat.addConnectionDelegate(self, identifier: "Connection_Delegate_\(config.groupId ?? "123123")")
        }

    }
    
    func appendMessageToTable(_ newMessage: BaseMessage) {
        // Assuming `messages` is your array that stores the chat messages
        self.messages.append(newMessage)

        // Updating the table view
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()

            // Scroll to the new message
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }


    // MARK: Send Message Button Handler
    @IBAction func sendMsgClickedd(_ sender: Any) {
        
        if let message = msgField.text, message.count > 0 {
            print("Message to send >> \(message)")
            AltibbiChat.chatChannel!.sendUserMessage(message, completionHandler: {userMsg, error in
                if error != nil {
                    print("sendUserMessage ERROR >>> \(error!.localizedDescription)")
                }
                print("sendUserMessage DONE >>> userMsg: \(String(describing: userMsg))")
                if let sentMessage: BaseMessage = userMsg {
                    self.messages += [sentMessage]
                }
                
            })
        }
    }
    
    @IBAction func addFilesClicked(_ sender: Any) {
        print("Current Messages >>>")
        for msg in self.messages {
            print("Message >>> Message ID: \(msg.messageId), Text: \(msg.message)")
        }
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
                        AltibbiChat.disconnectChat()
                        if let navigationController = self.navigationController {
                            if let viewControllerToPopTo = navigationController.viewControllers.first(where: { $0 is ConsultationVC }) {
                                navigationController.popToViewController(viewControllerToPopTo, animated: true)
                            }
                        }
                    }
                } else {
                    if cancelled != nil {
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
            })
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
}
