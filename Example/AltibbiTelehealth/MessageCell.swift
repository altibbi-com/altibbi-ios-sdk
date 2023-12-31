//
//  MessageCell.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 26/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class MessageCell: UITableViewCell {

    @IBOutlet weak var meessageContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    func configure(with message: BaseMessage) {
        messageLabel.text = message.message
        messageLabel.textAlignment = .right
        meessageContainer.layer.cornerRadius = 10.0
        meessageContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
    }
}
