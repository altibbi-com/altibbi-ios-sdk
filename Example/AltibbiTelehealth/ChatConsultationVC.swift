import UIKit
import AltibbiTelehealth
import SendbirdChatSDK
import MobileCoreServices

class ChatConsultationVC: UIViewController,
    GroupChannelDelegate, ConnectionDelegate,
    UITableViewDataSource, UITableViewDelegate,
    UIImagePickerControllerDelegate, UIDocumentPickerDelegate,
    UINavigationControllerDelegate {

    var consultationInfo: Consultation?
    var messages: [BaseMessage] = []
    var query: PreviousMessageListQuery?

    // MARK: - UI
    private let headerCard = UIView()
    private let backBtn = UIButton(type: .system)
    private let avatarImageView = UIImageView()
    private let consultationWithLbl = UILabel()
    private let doctorNameLbl = UILabel()
    private let endBtn = UIButton(type: .system)
    private let typingLbl = UILabel()

    private let tableView = UITableView()

    private let inputBar = UIView()
    private let inputBarFiller = UIView()
    private let inputTopBorder = UIView()
    private let msgField = UITextField()
    private let sendMsgBtn = UIButton(type: .system)
    private let addFilesBtn = UIButton(type: .system)

    private var inputBarBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupHeader()
        setupTableView()
        setupInputBar()
        registerKeyboardNotifications()
        initChat()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupHeader() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.backgroundColor = .white
        headerCard.applyShadow(opacity: 0.15, radius: 3, offset: CGSize(width: 0, height: 2))
        view.addSubview(headerCard)

        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = AppColors.text
        backBtn.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        headerCard.addSubview(backBtn)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.backgroundColor = UIColor(hex: "#F0F0F0")
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        headerCard.addSubview(avatarImageView)

        let nameStack = UIStackView()
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.axis = .vertical
        nameStack.spacing = 0
        headerCard.addSubview(nameStack)

        consultationWithLbl.text = "CONSULTATION WITH"
        consultationWithLbl.font = .systemFont(ofSize: 11, weight: .bold)
        consultationWithLbl.textColor = AppColors.gray
        consultationWithLbl.attributedText = NSAttributedString(
            string: "CONSULTATION WITH",
            attributes: [.kern: 0.55, .foregroundColor: AppColors.gray,
                         .font: UIFont.systemFont(ofSize: 11, weight: .bold)]
        )
        nameStack.addArrangedSubview(consultationWithLbl)

        doctorNameLbl.text = "Your Doctor"
        doctorNameLbl.font = .systemFont(ofSize: 16, weight: .bold)
        doctorNameLbl.textColor = AppColors.text
        nameStack.addArrangedSubview(doctorNameLbl)

        typingLbl.text = ""
        typingLbl.font = .systemFont(ofSize: 11)
        typingLbl.textColor = AppColors.primary
        nameStack.addArrangedSubview(typingLbl)

        endBtn.translatesAutoresizingMaskIntoConstraints = false
        endBtn.setTitle("End", for: .normal)
        endBtn.setTitleColor(AppColors.error, for: .normal)
        endBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        endBtn.backgroundColor = UIColor(red: 0xE4/255.0, green: 0x3F/255.0, blue: 0x3F/255.0, alpha: 0.15)
        endBtn.layer.cornerRadius = 8
        endBtn.layer.borderWidth = 1
        endBtn.layer.borderColor = UIColor(red: 0xE4/255.0, green: 0x3F/255.0, blue: 0x3F/255.0, alpha: 0.3).cgColor
        endBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        endBtn.addTarget(self, action: #selector(endBtnPressed), for: .touchUpInside)
        headerCard.addSubview(endBtn)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backBtn.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 12),
            backBtn.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),

            avatarImageView.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 8),
            avatarImageView.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            nameStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameStack.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            nameStack.trailingAnchor.constraint(lessThanOrEqualTo: endBtn.leadingAnchor, constant: -8),

            endBtn.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            endBtn.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),

            headerCard.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            avatarImageView.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 12),
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.register(MyMessageCell.self, forCellReuseIdentifier: "MyMessageCell")
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tableView)
    }

    private func setupInputBar() {
        inputBarFiller.translatesAutoresizingMaskIntoConstraints = false
        inputBarFiller.backgroundColor = .white
        view.addSubview(inputBarFiller)

        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.backgroundColor = .white
        view.addSubview(inputBar)

        inputTopBorder.translatesAutoresizingMaskIntoConstraints = false
        inputTopBorder.backgroundColor = UIColor(hex: "#EEEEEE")
        inputBar.addSubview(inputTopBorder)

        // Attach button: 36x36 circle, primary bg, white "+"
        addFilesBtn.translatesAutoresizingMaskIntoConstraints = false
        addFilesBtn.setTitle("+", for: .normal)
        addFilesBtn.setTitleColor(.white, for: .normal)
        addFilesBtn.titleLabel?.font = .systemFont(ofSize: 22, weight: .regular)
        addFilesBtn.backgroundColor = AppColors.primary
        addFilesBtn.layer.cornerRadius = 18
        addFilesBtn.clipsToBounds = true
        addFilesBtn.addTarget(self, action: #selector(addFilesClicked), for: .touchUpInside)
        inputBar.addSubview(addFilesBtn)

        // Message field: 44h, #F5F7FA bg, rounded 22, padding 16
        msgField.translatesAutoresizingMaskIntoConstraints = false
        msgField.placeholder = "Type a message…"
        msgField.font = .systemFont(ofSize: 15)
        msgField.textColor = AppColors.text
        msgField.borderStyle = .none
        msgField.backgroundColor = UIColor(hex: "#F5F7FA")
        msgField.layer.cornerRadius = 22
        msgField.layer.borderWidth = 1
        msgField.layer.borderColor = UIColor(hex: "#E1E4E8").cgColor
        msgField.clipsToBounds = true
        msgField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        msgField.leftViewMode = .always
        msgField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        msgField.rightViewMode = .always
        msgField.returnKeyType = .send
        msgField.delegate = self
        inputBar.addSubview(msgField)

        // Send button: 35x35 circle, primary bg, white "↑"
        sendMsgBtn.translatesAutoresizingMaskIntoConstraints = false
        sendMsgBtn.setTitle("↑", for: .normal)
        sendMsgBtn.setTitleColor(.white, for: .normal)
        sendMsgBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        sendMsgBtn.backgroundColor = AppColors.primary
        sendMsgBtn.layer.cornerRadius = 17.5
        sendMsgBtn.clipsToBounds = true
        sendMsgBtn.addTarget(self, action: #selector(sendMsgClicked), for: .touchUpInside)
        inputBar.addSubview(sendMsgBtn)

        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBarBottomConstraint,

            inputBarFiller.topAnchor.constraint(equalTo: inputBar.bottomAnchor),
            inputBarFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBarFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBarFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            inputTopBorder.topAnchor.constraint(equalTo: inputBar.topAnchor),
            inputTopBorder.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            inputTopBorder.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor),
            inputTopBorder.heightAnchor.constraint(equalToConstant: 1),

            addFilesBtn.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            addFilesBtn.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            addFilesBtn.widthAnchor.constraint(equalToConstant: 36),
            addFilesBtn.heightAnchor.constraint(equalToConstant: 36),

            msgField.leadingAnchor.constraint(equalTo: addFilesBtn.trailingAnchor, constant: 12),
            msgField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            msgField.heightAnchor.constraint(equalToConstant: 44),

            sendMsgBtn.leadingAnchor.constraint(equalTo: msgField.trailingAnchor, constant: 10),
            sendMsgBtn.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -16),
            sendMsgBtn.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendMsgBtn.widthAnchor.constraint(equalToConstant: 35),
            sendMsgBtn.heightAnchor.constraint(equalToConstant: 35),

            inputBar.topAnchor.constraint(equalTo: msgField.topAnchor, constant: -12),
        ])
    }

    // MARK: - Keyboard

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.inputBarBottomConstraint.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
        scrollToBottom()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.inputBarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Chat Init

    private func initChat() {
        guard let info = consultationInfo, let config = info.chatConfig else { return }

        DispatchQueue.main.async {
            if let name = info.doctorName {
                self.doctorNameLbl.text = name
            }
            if let avatarUrl = info.doctorAvatar, let url = URL(string: avatarUrl) {
                self.loadImage(url: url, into: self.avatarImageView)
            }
        }

        AltibbiChat.initialize(config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.query = AltibbiChat.chatChannel?.createPreviousMessageListQuery { params in
                params.limit = 100
                params.reverse = false
            }

            self.query?.loadNextPage { messages, error in
                if let error = error {
                    print("loadNextPage error: \(error.localizedDescription)")
                    return
                }
                if let oldMessages = messages {
                    DispatchQueue.main.async {
                        self.messages += oldMessages
                        self.tableView.reloadData()
                        self.scrollToBottom()
                        SendbirdChat.addChannelDelegate(self, identifier: "Channel_Delegate_\(config.groupId ?? "default")")
                        SendbirdChat.addConnectionDelegate(self, identifier: "Connection_Delegate_\(config.groupId ?? "default")")
                    }
                }
            }
        }
    }

    private func loadImage(url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView.image = img }
        }.resume()
    }

    func scrollToBottom() {
        DispatchQueue.main.async {
            guard self.messages.count > 0 else { return }
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let myUserId = consultationInfo?.chatConfig?.chatUserId

        if message.sender?.userId == myUserId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.configure(with: message, doctorAvatar: consultationInfo?.doctorAvatar)
            return cell
        }
    }

    // MARK: - GroupChannel Delegate

    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        print("didReceive >>> \(message.message)")
        DispatchQueue.main.async {
            self.messages += [message]
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    func channel(_ channel: GroupChannel, userDidLeave user: SendbirdChatSDK.User) {
        print("userDidLeave >>> \(user.userId)")
        DispatchQueue.main.async {
            self.msgField.isEnabled = false
            self.typingLbl.text = "Doctor left the consultation"
        }
        ApiService.cancelConsultation(id: (self.consultationInfo?.consultationId)!) { _, failure, error in
            if let error = error {
                print("cancelConsultation error: \(error)")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.closeConsultation()
            }
        }
    }

    func channelDidUpdateTypingStatus(_ channel: GroupChannel) {
        DispatchQueue.main.async {
            self.typingLbl.text = channel.isTyping() ? "Typing..." : ""
        }
    }

    // MARK: - Connection Delegate

    func didDisconnect(userId: String) {
        print("didDisconnect userId: \(userId)")
    }

    // MARK: - Actions

    @objc private func backButtonPressed() {
        showCancelAlert(title: "End Consultation", message: "Are you sure you want to end this consultation?")
    }

    @objc private func endBtnPressed() {
        showCancelAlert(title: "End Consultation", message: "Are you sure you want to end this consultation?")
    }

    @objc private func sendMsgClicked() {
        guard let message = msgField.text, !message.isEmpty else { return }
        sendMessage(msg: message)
    }

    func sendMessage(msg: String) {
        print("Sending message: \(msg)")
        AltibbiChat.chatChannel?.sendUserMessage(msg) { userMsg, error in
            if let error = error {
                print("sendUserMessage error: \(error.localizedDescription)")
                return
            }
            if let sentMessage = userMsg {
                DispatchQueue.main.async {
                    self.messages += [sentMessage]
                    self.tableView.reloadData()
                    self.scrollToBottom()
                    self.msgField.text = ""
                }
            }
        }
    }

    @objc private func addFilesClicked() {
        let alertController = UIAlertController(title: "Attach file", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.showCamera() })
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.showImagePicker() })
        alertController.addAction(UIAlertAction(title: "Document", style: .default) { _ in self.showFilePicker() })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    // MARK: - Pickers

    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera unavailable")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        present(imagePicker, animated: true)
    }

    func showFilePicker() {
        let types = [kUTTypePDF as String, kUTTypeImage as String, kUTTypeContent as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        let ext = fileURL.pathExtension.lowercased()
        do {
            let data = try Data(contentsOf: fileURL)
            let imageExts: Set<String> = ["jpg", "jpeg", "png", "gif", "heic", "webp"]
            let type = imageExts.contains(ext) ? "img" : (ext == "pdf" ? "pdf" : ext)
            handleFileUpload(data: data, type: type)
        } catch {
            print("Document read error: \(error)")
        }
    }

    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let pickedImage = info[.originalImage] as? UIImage,
           let imageData = pickedImage.jpegData(compressionQuality: 0.5) {
            handleFileUpload(data: imageData, type: "img")
        }
    }

    func handleFileUpload(data: Data, type: String) {
        ApiService.uploadMedia(jsonFile: data, type: type) { media, failure, error in
            if let error = error {
                print("uploadMedia error: \(error)")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else if let media = media, let url = media.url {
                self.sendMessage(msg: url)
            }
        }
    }

    // MARK: - Close Consultation

    func showCancelAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "End", style: .destructive) { _ in
            ApiService.cancelConsultation(id: (self.consultationInfo?.consultationId)!) { _, failure, error in
                if let error = error {
                    print("cancelConsultation error: \(error)")
                } else {
                    self.closeConsultation()
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        present(alert, animated: true)
    }

    func closeConsultation() {
        DispatchQueue.main.async {
            AltibbiChat.disconnectChat()
            if let vc = self.navigationController?.viewControllers.first(where: { $0 is ConsultationVC }) {
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChatConsultationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let message = textField.text, !message.isEmpty else { return false }
        sendMessage(msg: message)
        return true
    }
}

