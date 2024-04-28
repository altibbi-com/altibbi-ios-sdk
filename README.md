# AltibbiTelehealth

This swift SDK provides integration for the Altibbi services, including video consultation, text consultation, push
Welcome to the swift SDK for Altibbi services, your comprehensive solution for integrating health consultation services into your swift applications. This SDK enables video and text consultations, push notifications, and many other features to provide a seamless healthcare experience.
project.

## Features
- **Video and VOIP Consultation:** Facilitate live video and VOIP sessions between patients and healthcare professionals.
- **GSM Consultation:** Facilitate GSM(Phone calls) sessions between patients and healthcare professionals.
- **Text Consultation:** Offer real-time text messaging for healthcare inquiries.
- **User Management:** Easily manage user information with our comprehensive API.
- **Real-time Notifications:** Keep users updated with push notifications and server to server real time callbacks.

## Prerequisites
- Minimum IOS 13

## Installation

AltibbiTelehealth is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```sh
pod 'AltibbiTelehealth'
```

## Initialization
Initialize the Altibbi SDK with the following parameters:
- **token:** Authentication token from your backend.
- **baseUrl:** Your partner endpoint (will be shared with you upon request).
- **language:** Preferred language for responses either Arabic (default) or English.

```sh
AltibbiService.initService(token: token, baseUrl: baseUrl, language: "ar")
```

## Detailed Usage


### User API
Manage users with functions like `createUser`, `updateUser`,`getUser`, `getUsers`, and `deleteUser`. Below are examples of how to use these functions:

### USER API

| APi        | params         |
|------------|----------------|
| getUser    | id (required)  |
| getUsers   | page , perPage |
| createUser | userData       |
| updateUser | id , userData  |
| deleteUser | id             |

#### createUser Example

```sh
import AltibbiTelehealth

let newUser = User(name: 'Altibbi user')
ApiService.createUser(userData: newUser, completion: {user, failure, error in
    // Handle user as a User object
})
```

#### updateUser Example
```sh
import AltibbiTelehealth

var newUser = User(id: intId);
newUser.name = newName
ApiService.updateUser(id: intId, userData: newUser, completion: {updatedUser, failure, error in
    // Handle updatedUser as a User object
})
```

#### getUser Example
```sh
import AltibbiTelehealth

ApiService.getUser(id: intId, completion: {user, failure, error in
    // Handle user as a User object
})
```

#### getUsers Example
```sh
import AltibbiTelehealth

ApiService.getUsers(page: 1, perPage: 20, completion: {users, failure, error in
    // Handle users as an array of User object
})
```

#### deleteUser Example
```sh
import AltibbiTelehealth

ApiService.deleteUser(id: intId, completion: {data, failure, error in
    // Handle data as a String message 'Success'
})
```

### Consultation API
Create and manage consultations using our suite of functions:

| APi                 | params                              |
|---------------------|-------------------------------------|
| createConsultation  | consultation                        |
| uploadMedia         | jsonFile, type                      |
| getConsultationInfo | id                                  |
| getLastConsultation |                                     |
| getConsultationList | id (optional userId), page, perPage |
| deleteConsultation  | id                                  |
| cancelConsultation  | id                                  |

#### createConsultation
```sh
import AltibbiTelehealth

let consultation = Consultation(userId: intId, question: questionBody!, medium: medium, mediaIds: mediaIds)
ApiService.createConsultation(consultation: consultation, completion: {createdConsultation, failure, error in
    // Handle createdConsultation as a Consultation object
})
```

#### uploadMedia
```sh
import AltibbiTelehealth

ApiService.uploadMedia(jsonFile: data, type: type, completion: {media, failure, error in
    // Handle media as a Media object and add the id to the consultation mediaIds array
})
```

#### getConsultationInfo
```sh
import AltibbiTelehealth

let consultation = Consultation(userId: intId, question: questionBody!, medium: medium, mediaIds: mediaIds)
ApiService.getConsultationInfo(id: intId, completion: {consultation, failure, error in
    // Handle consultation as a Consultation object
})
```

#### getConsultationList
```sh
import AltibbiTelehealth

// With filtering on specific user
ApiService.getConsultationList(userId: filterId, page: 1, perPage: 20, completion: {list, failure, error in
    // Handle list as an array of Consultation object
})

// Without filteration
ApiService.getConsultationList(page: 1, perPage: 20, completion: {list, failure, error in
    // Handle list as an array of Consultation object
})
```

#### deleteConsultation
```sh
import AltibbiTelehealth

ApiService.deleteConsultation(id: intId, completion: {data, failure, error in
    // Handle data as a String message 'Success'
})
```

#### cancelConsultation
```sh
import AltibbiTelehealth

ApiService.cancelConsultation(id: intId, completion: {cancelledConsultation, failure, error in
    // Handle cancelledConsultation as a CancelledConsultation object
})
```

### TBISocket
#### After creating the consultation you can use TBISocket to listen to consultation status events

```sh
import AltibbiTelehealth
// get appKey and channelName from the created consultation info
// declare a function 'onEvent' to get the events from the socket

func onEvent(name: String, data: String?) {
    if let data = data {
        if data == "accepted" {
            // This indicates that doctor accepted the consultation but still not started
        } else if data == "in_progress" {
            // This indicates that consultation started
        }
    }
}
TBISocket.initiateSocket(
    appKey: appKey,
    channelName: channelName,
    onEvent: onEvent
)
```

### Chat Consultation
Import related libs
```sh
import AltibbiTelehealth
import SendbirdChatSDK
import MobileCoreServices // For Image and File Pickers and handling sending them
```
Handle Chat display by using UITableView and implementing the related protocols UITableViewDataSource, UITableViewDelegate
```sh
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
```

Handle chat connection and events by implementing the related protocols GroupChannelDelegate, ConnectionDelegate
```sh
func didDisconnect(userId: String)
func channel(_ channel: BaseChannel, didReceive message: BaseMessage)
func channel(_ channel: GroupChannel, userDidLeave user: SendbirdChatSDK.User)
func channelDidUpdateTypingStatus(_ channel: GroupChannel)
```

Registering chat cell for TableView
```sh
tableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
// MARK: File messages could be handled by checking if the message is a link then a new custom cell is needed
```

Initialize chat
```sh
// Get the chatConfig from the consultation info
AltibbiChat.initialize(config: info.chatConfig!)
```

For loading all messages
```sh
@IBOutlet weak var tableView: UITableView!
var messages: [BaseMessage] = []
var query: PreviousMessageListQuery?
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    self.query = AltibbiChat.chatChannel!.createPreviousMessageListQuery { params in
        params.limit = 100
        params.reverse = false
    }
    self.query!.loadNextPage(completionHandler: { messages, error in
        guard error == nil else {
            return
        }

        if let oldMessages = messages {
            DispatchQueue.main.async {
                self.messages += oldMessages
                self.tableView.reloadData()
                SendbirdChat.addChannelDelegate(self, identifier: "Channel_Delegate_\(config.groupId ?? "123123")")
                SendbirdChat.addConnectionDelegate(self, identifier: "Connection_Delegate_\(config.groupId ?? "123123")")
            }
        }
    })
}
```

For Sending a message
```sh
func sendMessage(msg: String) {
    AltibbiChat.chatChannel!.sendUserMessage(msg, completionHandler: {userMsg, error in
        if error != nil {
            print("sendUserMessage ERROR >>> \(error!.localizedDescription)")
        }
        if let sentMessage: BaseMessage = userMsg {
            DispatchQueue.main.async {
                self.messages += [sentMessage]
                self.tableView.reloadData()
                self.msgField.text = ""
            }

        }
    })
}
```

### Video Consultation
#### Check the example project, VideoConsultationVC file


For support, contact: [mobile@altibbi.com](mobile@altibbi.com). Please
ensure that you are referencing the latest version of the SDK to access all available features and improvements.

## License

AltibbiTelehealth is available under the MIT license.
