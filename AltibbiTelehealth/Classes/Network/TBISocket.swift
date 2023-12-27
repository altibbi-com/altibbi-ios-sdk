//
//  PusherSocket.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 07/12/2023.
//

import Foundation
import PusherSwift

public class TBChannel: PusherChannel {
    init(channel: PusherChannel) {
        super.init(name: channel.name, connection: channel.connection!)
    }
}

public class TBISocket: Pusher {
    private static var socket: TBISocket!
    private static var channel: TBChannel!
    
    public static func initiateSocket(
        appKey: String,
        channelName: String,
        onEvent: @escaping (String, String?) -> Void
    ) -> Void {
        print("From initiateSocket, AltibbiService.baseUrl: \(String(describing: AltibbiService.baseUrl))")
        print("From initiateSocket, AltibbiService.token: \(String(describing: AltibbiService.token))")
        let decoder = JSONDecoder()
        if let baseUrl = AltibbiService.baseUrl, let token = AltibbiService.token {
            let endPointStr = "https://\(baseUrl)/v1/auth/pusher?access-token=\(token)"
            let options = PusherClientOptions(
                authMethod: .endpoint(authEndpoint: endPointStr),
                host: .cluster("eu")
            )
            
            socket = TBISocket(key: appKey, options: options)
            socket.bind(eventCallback: {(event: PusherEvent) -> Void in
                let conferenceEvents = ["video-conference-ready", "chat-conference-ready", "voip-conference-ready"]
                if event.eventName == "call-status" {
                    guard let data = event.data, let jsonData = data.data(using: .utf8) else {
                        if let data = event.data {
                            onEvent(event.eventName, data)
                        }
                        return
                    }
                    do {
                        let callStatus = try decoder.decode(CallStatus.self, from: jsonData)
                        onEvent(event.eventName, callStatus.status)
                        if callStatus.status == "in_progress" || callStatus.status == "closed" {
                            socket.disconnect()
                        }
                    } catch {
                        onEvent(event.eventName, "Failed To Decode CallStatus Event Data")
                    }
                } else if conferenceEvents.contains(event.eventName) {
                    onEvent(event.eventName, "accepted")
                } else {
                    if let data = event.data {
                        onEvent(event.eventName, data)
                    }
                }
                
            })
            
            socket.connect()
            channel = TBChannel(channel: TBISocket.socket.subscribe(channelName: channelName))
        }
    }
    
    public static func getSocket() -> TBISocket {
        return socket
    }
    
    public static func getChannel() -> TBChannel {
        return channel
    }
}

public class CallStatus: Codable {
    private(set) public var status: String
}
