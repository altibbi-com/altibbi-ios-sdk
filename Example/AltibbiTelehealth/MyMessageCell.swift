//
//  MyMessageCell.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 26/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class MyMessageCell: UITableViewCell {

    @IBOutlet weak var myMessageContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    func configure(with message: BaseMessage) {
        messageLabel.text = message.message
        messageLabel.textAlignment = .right
        myMessageContainer.layer.cornerRadius = 10.0
        myMessageContainer.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
    }
}
