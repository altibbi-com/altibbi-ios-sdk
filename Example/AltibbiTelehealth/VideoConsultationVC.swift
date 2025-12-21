//
//  VideoConsultationVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Alshtayyat on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import AltibbiTelehealth
// NOTE: For video consultation, add Vonage Video SDK via SPM:
//   File → Add Package Dependencies → https://github.com/vonage/vonage-video-client-sdk-swift.git
//   Version: Choose "Up to Next Major Version" from 2.32.1
//   Then import: import VonageClientSDKVideo
//   Also add -ObjC to "Other Linker Flags" in Build Settings (required)
//   See: https://github.com/vonage/vonage-video-client-sdk-swift
//
// For now, this file uses OpenTok (requires manual framework addition):
import OpenTok

// *** Fill the following variables using your own Project info  ***
// ***            https://tokbox.com/account/#/                  ***
// Replace with your OpenTok API key
let kApiKey = ""
// Replace with your generated session ID
let kSessionId = ""
// Replace with your generated token
let kToken = ""

let kWidgetHeight = 240
let kWidgetWidth = 320


class VideoConsultationVC: UIViewController {
    lazy var session: OTSession = {
        if (consultationInfo?.medium == "voip") {
            return OTSession(apiKey: consultationInfo?.voipConfig?.apiKey ?? "", sessionId: consultationInfo?.voipConfig?.callId ?? "", delegate: self)!
        }
        return OTSession(apiKey: consultationInfo?.videoConfig?.apiKey ?? "", sessionId: consultationInfo?.videoConfig?.callId ?? "", delegate: self)!
    }()

    var consultationInfo: Consultation?

    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        if (consultationInfo?.medium == "voip") {
            settings.videoTrack = false
        }
        return OTPublisher(delegate: self, settings: settings)!
    }()

    var subscriber: OTSubscriber?

    @IBAction func muteButtonTapped(_ sender: UIButton) {
        publisher.publishAudio = !publisher.publishAudio

        if publisher.publishAudio {
            sender.setTitle("Mute", for: .normal)
        } else {
            sender.setTitle("Unmute", for: .normal)
        }
    }
    @IBAction func switchCameraButtonTapped(_ sender: UIButton) {
        if publisher.cameraPosition == .front {
            publisher.cameraPosition = .back
            sender.setTitle("Front Camera", for: .normal)
        } else {
            publisher.cameraPosition = .front
            sender.setTitle("Rear Camera", for: .normal)
        }
    }
    @IBAction func toggleVideoButtonTapped(_ sender: UIButton) {
        publisher.publishVideo = !publisher.publishVideo

        if publisher.publishVideo {
            sender.setTitle("Disable Video", for: .normal)
        } else {
            sender.setTitle("Enable Video", for: .normal)
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

    @IBAction func endCallButtonTapped(_ sender: UIButton) {
        var error: OTError?
        session.disconnect(&error)

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

    var scrollView: UIScrollView!
    func setupScrollView() {
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(scrollView)
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()



        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 250
        let buttonSpacing: CGFloat = 10
        var yOffset: CGFloat = 500

        let muteButton = UIButton(frame: CGRect(x: 20, y: yOffset, width: buttonWidth, height: buttonHeight))
        muteButton.setTitle("Mute", for: .normal)
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        muteButton.backgroundColor = .gray
        scrollView.addSubview(muteButton)
        yOffset += buttonHeight + buttonSpacing


        if (consultationInfo?.medium == "video") {

            let switchCameraButton = UIButton(frame: CGRect(x: 20, y: yOffset, width: buttonWidth, height: buttonHeight))
            switchCameraButton.setTitle("Rear Camera", for: .normal)
            switchCameraButton.addTarget(self, action: #selector(switchCameraButtonTapped), for: .touchUpInside)
            switchCameraButton.backgroundColor = .green
            scrollView.addSubview(switchCameraButton)
            yOffset += buttonHeight + buttonSpacing

            let toggleVideoButton = UIButton(frame: CGRect(x: 20, y: yOffset, width: buttonWidth, height: buttonHeight))
            toggleVideoButton.setTitle("Disable Video", for: .normal)
            toggleVideoButton.backgroundColor = .blue
            toggleVideoButton.addTarget(self, action: #selector(toggleVideoButtonTapped), for: .touchUpInside)
            scrollView.addSubview(toggleVideoButton)
            yOffset += buttonHeight + buttonSpacing
        }

        let endCallButton = UIButton(frame: CGRect(x: 20, y: yOffset, width: buttonWidth, height: buttonHeight))
        endCallButton.setTitle("End Call", for: .normal)
        endCallButton.backgroundColor = .red
        endCallButton.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)

        scrollView.addSubview(endCallButton)
        yOffset += buttonHeight + buttonSpacing

        scrollView.contentSize = CGSize(width: view.frame.width, height: yOffset)


        doConnect()
    }

    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        session.connect(withToken: consultationInfo?.medium == "voip" ? (consultationInfo?.voipConfig?.token ?? "") : (consultationInfo?.videoConfig?.token ?? ""), error: &error)
    }

    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }

        session.publish(publisher, error: &error)

        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: kWidgetWidth, height: kWidgetHeight)
            if (consultationInfo?.medium == "video"){
                scrollView.addSubview(pubView)
            }
            //view.addSubview(pubView)
        }
    }

    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)

        session.subscribe(subscriber!, error: &error)
    }

    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }

    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }

    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - OTSession delegate callbacks
extension VideoConsultationVC: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }

    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }

}

// MARK: - OTPublisher delegate callbacks
extension VideoConsultationVC: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }

    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }

    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension VideoConsultationVC: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            subsView.frame = CGRect(x: 0, y: kWidgetHeight, width: kWidgetWidth, height: kWidgetHeight)
            scrollView.addSubview(subsView)
            //view.addSubview(subsView)
        }
    }

    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
