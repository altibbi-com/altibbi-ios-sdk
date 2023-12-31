//
//  AltibbiChat.swift
//  AltibbiTelehealth
//
//  Created by Mahmoud Johar on 24/12/2023.
//
// "SENDBIRD_APP_ID": "DDD1D3D0-8CDB-4057-BC7F-FEC8213C0BDB", LIVE
// "SENDBIRD_APP_ID": "4215563D-E399-4895-ABB6-D209582A735A", DEV

import Foundation
import SendbirdChatSDK

public class AltibbiChat {
    public static var chatChannel: GroupChannel?
    public static func initialize(config: ChatConfig) {
        let initParams = InitParams(
            applicationId: config.appId!,
            logLevel: .info
        )
        
        // MARK: Initialize
        SendbirdChat.initialize(params: initParams, completionHandler: {error in
            if let error = error {
                print("SendbirdChat.initialize Error: \(error.localizedDescription)")
            }
            print("SendbirdChat.initialize >>> DONE!")
        })
        
        // MARK: Connect
        SendbirdChat.connect(userId: config.chatUserId!, authToken: config.chatUserToken, completionHandler: {user, error in
            guard let user = user, error == nil else {
                print("SendbirdChat.connect Not Connected !")
                if error != nil {
                    print("Error >> \(error!.localizedDescription)")
                }
                return
            }
            
            print("SendbirdChat.connect CONNECTED, \(String(describing: user))")
            
            if let channelId: String = config.groupId {
                GroupChannel.getChannel(url: "channel_\(channelId)", completionHandler: {channel, error in
                    if error != nil {
                        print("GroupChannel.getChannel Error: \(error!.localizedDescription)")
                        return
                    }
                    if let channel = channel {
                        print("GroupChannel.getChannel >>> \(String(describing: channel))")
                        AltibbiChat.chatChannel = channel
                    }
                })
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1200.0) {
//                SendbirdChat.disconnect(completionHandler: {
//                    print("SendbirdChat.disconnect >>> Disconnected")
//                })
//            }
        })
    }
    
    public static func disconnectChat() {
        SendbirdChat.disconnect(completionHandler: {
            print("SendbirdChat.disconnect >>> Disconnected")
        })
    }
    
    public static func addChannelDelegate(_ delegate: SendbirdChatSDK.BaseChannelDelegate, identifier: String) {
        SendbirdChat.addChannelDelegate(delegate, identifier: identifier)
    }
    
    public static func addConnectionDelegate(_ delegate: SendbirdChatSDK.ConnectionDelegate, identifier: String) {
        SendbirdChat.addChannelDelegate(delegate as! BaseChannelDelegate, identifier: identifier)
    }
}

public class AltibbiChatMessage: BaseMessage {
    
}

public class AltibbiChatChannel: BaseChannel {
    
}

public class AltibbiPreviousMessageListQuery {
    public static var query: PreviousMessageListQuery? = nil
}

public protocol AltibbiChatChannelDelegate: GroupChannelDelegate {
    associatedtype AltibbiChannel: BaseChannel
    associatedtype AltibbiMessage: BaseMessage

    func channel(_ channel: AltibbiChannel, didReceive message: AltibbiMessage)
}

public protocol AltibbiChatConnectionDelegate: ConnectionDelegate, BaseChannelDelegate {
    
}

