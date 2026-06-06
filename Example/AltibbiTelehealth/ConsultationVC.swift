import UIKit
import AltibbiTelehealth
import MobileCoreServices

// MARK: - ConsultationVC

class ConsultationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    // MARK: Scroll
    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // MARK: New Consultation
    private let mediumRadio   = RadioGroupView(title: "Select Medium", options: ["chat", "gsm", "video", "voip"])
    private let userIdField   = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let questionField = AppTextViewField(label: "Question", placeholder: "Medical consultation question (min 10 chars)…")
    private let attachBtn     = AppButton(title: "Attach Media (Optional)", variant: .secondary)
    private let previewImage  = UIImageView()
    private let removeMediaBtn = UIButton(type: .system)
    private let uploadingIndicator = UIActivityIndicatorView(style: .medium)
    private let createBtn     = AppButton(title: "Create Consultation")
    private let goActiveBtn   = AppButton(title: "Go to Active Consultation", variant: .secondary)
    private let createFeedback = FeedbackView()

    // MARK: State
    private var mediaId: String?
    private var previewUri: String?
    private var isUploading = false
    private var isCreating  = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consultation"
        view.backgroundColor = AppColors.background
        setupScrollView()
        setupContent()
        setupKeyboardDismiss()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        fetchMainUserId()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMainUserId()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func fetchMainUserId() {
        ApiService.getUsers(page: 1, perPage: 1) { [weak self] users, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let id = users?.first?.id {
                    self.userIdField.text = "\(id)"
                } else {
                    self.createFeedback.show(message: "Failed to auto-fill User ID: \(error?.localizedDescription ?? "no users found")", type: .error)
                }
            }
        }
    }

    // MARK: - Scroll Setup

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    private func setupContent() {
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis    = .vertical
        outerStack.spacing = AppLayout.spacing
        contentView.addSubview(outerStack)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        outerStack.addArrangedSubview(buildNewConsultationCard())
    }

    // MARK: - Card Builders

    private func buildNewConsultationCard() -> UIView {
        let card = AppCardView()
        let stack = cardStack()
        card.addSubview(stack)
        pinStack(stack, to: card)

        let title = SectionTitleLabel("New Consultation")
        let divider = SectionDivider()
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(divider)
        stack.addArrangedSubview(mediumRadio)
        stack.addArrangedSubview(userIdField)
        stack.addArrangedSubview(questionField)

        // Media container
        let mediaContainer = buildMediaContainer()
        stack.addArrangedSubview(mediaContainer)

        stack.addArrangedSubview(createFeedback)
        stack.addArrangedSubview(createBtn)
        stack.addArrangedSubview(goActiveBtn)

        createBtn.addTarget(self, action: #selector(submitConsultation), for: .touchUpInside)
        goActiveBtn.addTarget(self, action: #selector(goToActiveConsultation), for: .touchUpInside)

        return card
    }

    private func buildMediaContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Attach button (default state)
        attachBtn.translatesAutoresizingMaskIntoConstraints = true
        attachBtn.addTarget(self, action: #selector(pickMedia), for: .touchUpInside)
        container.addSubview(attachBtn)
        NSLayoutConstraint.activate([
            attachBtn.topAnchor.constraint(equalTo: container.topAnchor),
            attachBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            attachBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        // Uploading indicator
        uploadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        uploadingIndicator.color = AppColors.primary
        uploadingIndicator.hidesWhenStopped = true
        container.addSubview(uploadingIndicator)
        NSLayoutConstraint.activate([
            uploadingIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            uploadingIndicator.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
        ])

        // Preview image
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        previewImage.contentMode = .scaleAspectFill
        previewImage.clipsToBounds = true
        previewImage.layer.cornerRadius = 12
        previewImage.backgroundColor = AppColors.lightGray
        previewImage.isHidden = true
        container.addSubview(previewImage)
        NSLayoutConstraint.activate([
            previewImage.topAnchor.constraint(equalTo: container.topAnchor),
            previewImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            previewImage.widthAnchor.constraint(equalToConstant: 100),
            previewImage.heightAnchor.constraint(equalToConstant: 100),
        ])

        // Remove badge
        removeMediaBtn.translatesAutoresizingMaskIntoConstraints = false
        removeMediaBtn.setTitle("×", for: .normal)
        removeMediaBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .black)
        removeMediaBtn.setTitleColor(.white, for: .normal)
        removeMediaBtn.backgroundColor = AppColors.error
        removeMediaBtn.layer.cornerRadius = 12
        removeMediaBtn.isHidden = true
        removeMediaBtn.addTarget(self, action: #selector(removeMedia), for: .touchUpInside)
        container.addSubview(removeMediaBtn)
        NSLayoutConstraint.activate([
            removeMediaBtn.topAnchor.constraint(equalTo: previewImage.topAnchor, constant: -8),
            removeMediaBtn.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor, constant: 8),
            removeMediaBtn.widthAnchor.constraint(equalToConstant: 24),
            removeMediaBtn.heightAnchor.constraint(equalToConstant: 24),
        ])

        // Container height anchors
        let normalHeight = container.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight)
        normalHeight.isActive = true

        attachBtn.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight).isActive = true
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: AppLayout.buttonHeight).isActive = false

        return container
    }

    // MARK: - Helpers

    private func cardStack() -> UIStackView {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical; s.spacing = AppLayout.spacing
        return s
    }

    private func pinStack(_ stack: UIStackView, to card: UIView) {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
    }

    // MARK: - Media

    @objc private func pickMedia() {
        let picker = UIImagePickerController()
        picker.delegate = self; picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 0.7) else { return }
        previewImage.image = image
        showUploadingState(true)
        ApiService.uploadMedia(jsonFile: data, type: "jpg") { [weak self] media, _, error in
            DispatchQueue.main.async {
                self?.showUploadingState(false)
                if let id = media?.id {
                    self?.mediaId = id
                    self?.showPreviewState(true)
                } else {
                    self?.createFeedback.show(message: "Failed to upload image.", type: .error)
                }
            }
        }
    }

    @objc private func removeMedia() {
        mediaId = nil; previewImage.image = nil
        showPreviewState(false)
    }

    private func showUploadingState(_ uploading: Bool) {
        if uploading {
            attachBtn.isHidden = true; previewImage.isHidden = true; removeMediaBtn.isHidden = true
            uploadingIndicator.startAnimating()
        } else {
            uploadingIndicator.stopAnimating()
            if mediaId == nil { attachBtn.isHidden = false }
        }
    }

    private func showPreviewState(_ hasMedia: Bool) {
        attachBtn.isHidden   = hasMedia
        previewImage.isHidden = !hasMedia
        removeMediaBtn.isHidden = !hasMedia
    }

    // MARK: - Submit Consultation

    @objc private func submitConsultation() {
        let question = questionField.text ?? ""
        guard question.count >= 10 else {
            createFeedback.show(message: "Question must be at least 10 characters.", type: .error); return
        }
        guard let userIdText = userIdField.text, let userId = Int(userIdText) else {
            createFeedback.show(message: "Valid User ID is required.", type: .error); return
        }
        let medium = mediumRadio.selectedValue
        guard !medium.isEmpty else {
            createFeedback.show(message: "Please select a medium.", type: .error); return
        }

        isCreating = true; createBtn.setLoading(true); createFeedback.hide()

        let consultation = Consultation(
            userId: userId, question: question, medium: medium,
            mediaIds: mediaId.map { [$0] },
            scheduledTo: nil, parentConsultationId: nil
        )
        ApiService.createConsultation(consultation: consultation, forceWhiteLabelingPartnerName: "partnerTest") { [weak self] _, _, error in
            DispatchQueue.main.async {
                self?.createBtn.setLoading(false); self?.isCreating = false
                if error != nil {
                    self?.createFeedback.show(message: "Failed to create consultation.", type: .error)
                } else {
                    self?.fetchAndNavigateToActive()
                }
            }
        }
    }

    @objc private func goToActiveConsultation() { fetchAndNavigateToActive() }

    private func fetchAndNavigateToActive() {
        ApiService.getLastConsultation { [weak self] consultation, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let c = consultation, c.status != "closed" {
                    let waitVC = WaitingVC()
                    waitVC.consultationInfo = c
                    self.navigationController?.pushViewController(waitVC, animated: true)
                } else {
                    self.createFeedback.show(message: "No active consultation found.", type: .info)
                }
            }
        }
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ n: Notification) {
        if let info = n.userInfo, let val = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            scrollView.contentInset.bottom = val.cgRectValue.height
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) { scrollView.contentInset.bottom = 0 }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
