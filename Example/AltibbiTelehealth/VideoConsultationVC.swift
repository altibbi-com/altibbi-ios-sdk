import UIKit
import AltibbiTelehealth
import OpenTok

class VideoConsultationVC: UIViewController {

    var consultationInfo: Consultation?

    lazy var session: OTSession = {
        if consultationInfo?.medium == "voip" {
            return OTSession(apiKey: consultationInfo?.voipConfig?.apiKey ?? "",
                             sessionId: consultationInfo?.voipConfig?.callId ?? "", delegate: self)!
        }
        return OTSession(apiKey: consultationInfo?.videoConfig?.apiKey ?? "",
                         sessionId: consultationInfo?.videoConfig?.callId ?? "", delegate: self)!
    }()

    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        if consultationInfo?.medium == "voip" { settings.videoTrack = false }
        return OTPublisher(delegate: self, settings: settings)!
    }()

    var subscriber: OTSubscriber?

    private let subscriberContainer = UIView()
    private let waitingLbl = UILabel()
    private let publisherContainer = UIView()
    private let controlsRow = UIStackView()

    private let videoBtn = UIButton(type: .system)
    private let audioBtn = UIButton(type: .system)
    private let endBtn = UIButton(type: .system)
    private let flipBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        doConnect()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        subscriberContainer.translatesAutoresizingMaskIntoConstraints = false
        subscriberContainer.backgroundColor = UIColor(hex: "#222222")
        view.addSubview(subscriberContainer)

        waitingLbl.translatesAutoresizingMaskIntoConstraints = false
        waitingLbl.text = "Waiting for doctor to join…"
        waitingLbl.font = .systemFont(ofSize: 18, weight: .bold)
        waitingLbl.textColor = .white
        waitingLbl.textAlignment = .center
        subscriberContainer.addSubview(waitingLbl)

        publisherContainer.translatesAutoresizingMaskIntoConstraints = false
        publisherContainer.backgroundColor = UIColor(hex: "#444444")
        publisherContainer.layer.cornerRadius = 12
        publisherContainer.clipsToBounds = true
        publisherContainer.layer.borderWidth = 2
        publisherContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        publisherContainer.isHidden = consultationInfo?.medium == "voip"
        view.addSubview(publisherContainer)

        videoBtn.translatesAutoresizingMaskIntoConstraints = false
        styleControl(videoBtn, system: "video.fill", size: 60, bg: .white, tint: AppColors.text)
        videoBtn.addTarget(self, action: #selector(toggleVideo), for: .touchUpInside)

        audioBtn.translatesAutoresizingMaskIntoConstraints = false
        styleControl(audioBtn, system: "mic.fill", size: 60, bg: .white, tint: AppColors.text)
        audioBtn.addTarget(self, action: #selector(toggleAudio), for: .touchUpInside)

        endBtn.translatesAutoresizingMaskIntoConstraints = false
        styleControl(endBtn, system: "xmark", size: 70, bg: AppColors.error, tint: .white, sfWeight: .bold)
        endBtn.addTarget(self, action: #selector(endCall), for: .touchUpInside)

        flipBtn.translatesAutoresizingMaskIntoConstraints = false
        styleControl(flipBtn, system: "camera.rotate.fill", size: 60, bg: .white, tint: AppColors.text)
        flipBtn.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        flipBtn.isHidden = consultationInfo?.medium == "voip"

        controlsRow.translatesAutoresizingMaskIntoConstraints = false
        controlsRow.axis = .horizontal
        controlsRow.spacing = 16
        controlsRow.alignment = .center
        controlsRow.distribution = .equalSpacing
        if !flipBtn.isHidden { controlsRow.addArrangedSubview(flipBtn) }
        controlsRow.addArrangedSubview(endBtn)
        controlsRow.addArrangedSubview(audioBtn)
        if !videoBtn.isHidden, consultationInfo?.medium != "voip" {
            controlsRow.addArrangedSubview(videoBtn)
        }
        view.addSubview(controlsRow)

        NSLayoutConstraint.activate([
            subscriberContainer.topAnchor.constraint(equalTo: view.topAnchor),
            subscriberContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subscriberContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subscriberContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            waitingLbl.centerXAnchor.constraint(equalTo: subscriberContainer.centerXAnchor),
            waitingLbl.centerYAnchor.constraint(equalTo: subscriberContainer.centerYAnchor),

            publisherContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            publisherContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            publisherContainer.widthAnchor.constraint(equalToConstant: 120),
            publisherContainer.heightAnchor.constraint(equalToConstant: 160),

            controlsRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            controlsRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func styleControl(_ btn: UIButton, system: String, size: CGFloat, bg: UIColor, tint: UIColor, sfWeight: UIImage.SymbolWeight = .regular) {
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        btn.backgroundColor = bg
        btn.layer.cornerRadius = size / 2
        btn.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.4, weight: sfWeight)
        btn.setImage(UIImage(systemName: system, withConfiguration: config), for: .normal)
        btn.tintColor = tint
    }

    @objc private func toggleVideo() {
        publisher.publishVideo = !publisher.publishVideo
        let sys = publisher.publishVideo ? "video.fill" : "video.slash.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        videoBtn.setImage(UIImage(systemName: sys, withConfiguration: config), for: .normal)
        videoBtn.backgroundColor = publisher.publishVideo ? .white : UIColor.white.withAlphaComponent(0.3)
    }

    @objc private func toggleAudio() {
        publisher.publishAudio = !publisher.publishAudio
        let sys = publisher.publishAudio ? "mic.fill" : "mic.slash.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        audioBtn.setImage(UIImage(systemName: sys, withConfiguration: config), for: .normal)
        audioBtn.backgroundColor = publisher.publishAudio ? .white : UIColor.white.withAlphaComponent(0.3)
    }

    @objc private func flipCamera() {
        publisher.cameraPosition = publisher.cameraPosition == .front ? .back : .front
    }

    @objc private func endCall() {
        var error: OTError?
        session.disconnect(&error)
        guard let info = consultationInfo else { return }
        ApiService.cancelConsultation(id: Int(info.consultationId!)) { _, failure, error in
            if let error = error {
                print("cancelConsultation error: \(error)")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Call Ended", message: "Consultation ended successfully") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    fileprivate func doConnect() {
        var error: OTError?
        defer { processError(error) }
        let token = consultationInfo?.medium == "voip"
            ? (consultationInfo?.voipConfig?.token ?? "")
            : (consultationInfo?.videoConfig?.token ?? "")
        session.connect(withToken: token, error: &error)
    }

    fileprivate func doPublish() {
        var error: OTError?
        defer { processError(error) }
        session.publish(publisher, error: &error)
        if let pubView = publisher.view, consultationInfo?.medium == "video" {
            pubView.translatesAutoresizingMaskIntoConstraints = false
            publisherContainer.addSubview(pubView)
            NSLayoutConstraint.activate([
                pubView.topAnchor.constraint(equalTo: publisherContainer.topAnchor),
                pubView.leadingAnchor.constraint(equalTo: publisherContainer.leadingAnchor),
                pubView.trailingAnchor.constraint(equalTo: publisherContainer.trailingAnchor),
                pubView.bottomAnchor.constraint(equalTo: publisherContainer.bottomAnchor),
            ])
        }
    }

    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer { processError(error) }
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
        guard let err = error else { return }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension VideoConsultationVC: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) { doPublish() }
    func sessionDidDisconnect(_ session: OTSession) {}
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        if subscriber == nil { doSubscribe(stream) }
    }
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
            guard let info = consultationInfo else { return }
            ApiService.cancelConsultation(id: Int(info.consultationId!)) { _, failure, error in
                if let error = error {
                    print("cancelConsultation error: \(error)")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                }
                DispatchQueue.main.async {
                    self.showAlert(title: "Call Ended", message: "The doctor has ended the call.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("Session failed: \(error.localizedDescription)")
    }
}

extension VideoConsultationVC: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {}
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

extension VideoConsultationVC: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            subsView.translatesAutoresizingMaskIntoConstraints = false
            waitingLbl.isHidden = true
            subscriberContainer.addSubview(subsView)
            subscriberContainer.sendSubviewToBack(subsView)
            NSLayoutConstraint.activate([
                subsView.topAnchor.constraint(equalTo: subscriberContainer.topAnchor),
                subsView.leadingAnchor.constraint(equalTo: subscriberContainer.leadingAnchor),
                subsView.trailingAnchor.constraint(equalTo: subscriberContainer.trailingAnchor),
                subsView.bottomAnchor.constraint(equalTo: subscriberContainer.bottomAnchor),
            ])
        }
    }
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
