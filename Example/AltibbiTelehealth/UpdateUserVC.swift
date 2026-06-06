import UIKit
import AltibbiTelehealth

class UpdateUserVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // Load section
    private let userIdField  = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let loadBtn      = AppButton(title: "Load User", variant: .secondary)
    private let loadFeedback = FeedbackView()

    // Edit fields
    private let nameField         = AppTextFieldView(label: "Name", placeholder: "Full name")
    private let dobField          = AppTextFieldView(label: "Date of Birth", placeholder: "YYYY-MM-DD")
    private let genderRadio       = RadioGroupView(title: "Gender", options: ["male", "female"])
    private let maritalRadio      = RadioGroupView(title: "Marital Status", options: ["single", "married", "divorced", "widow"])
    private let emailField        = AppTextFieldView(label: "Email", placeholder: "email@example.com", keyboardType: .emailAddress)
    private let phoneField        = AppTextFieldView(label: "Phone", placeholder: "Phone Number", keyboardType: .phonePad)
    private let nationalityField  = AppTextFieldView(label: "Nationality Number", placeholder: "Nationality Number")
    private let insuranceField    = AppTextFieldView(label: "Insurance ID", placeholder: "Insurance ID")
    private let policyField       = AppTextFieldView(label: "Policy Number", placeholder: "Policy Number")
    private let tpaCodeField      = AppTextFieldView(label: "TPA Code", placeholder: "TPA Code")
    private let payerNameField    = AppTextFieldView(label: "Payer Name", placeholder: "Payer Name")
    private let heightField       = AppTextFieldView(label: "Height (cm)", placeholder: "Height", keyboardType: .decimalPad)
    private let weightField       = AppTextFieldView(label: "Weight (kg)", placeholder: "Weight", keyboardType: .decimalPad)
    private let bloodTypeRadio    = RadioGroupView(title: "Blood Type", options: ["A+", "B+", "AB+", "O+", "A-", "B-", "AB-", "O-"])
    private let smokerRadio       = RadioGroupView(title: "Smoker", options: ["no", "yes"])
    private let alcoholicRadio    = RadioGroupView(title: "Alcoholic", options: ["no", "yes"])
    private let relationRadio     = RadioGroupView(title: "Relation Type", options: ["personal", "father", "mother", "sister", "brother", "child", "husband", "wife", "other"])
    private let saveFeedback      = FeedbackView()
    private let saveBtn           = AppButton(title: "Save Changes")

    private var loadedUserId: Int?
    private var selectedDate: Date = Date()
    private var datePickerOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Update User"
        view.backgroundColor = AppColors.background
        setupScrollView()
        setupContent()
        saveBtn.isEnabled = false
        saveBtn.alpha = 0.5
        setupKeyboardDismiss()
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        ApiService.getUsers(page: 1, perPage: 1) { [weak self] users, _, _ in
            DispatchQueue.main.async {
                guard let self, let id = users?.first?.id else { return }
                if self.userIdField.text?.isEmpty == false { return }
                self.userIdField.text = "\(id)"
            }
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Scroll

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

    // MARK: - Content

    private func setupContent() {
        let outer = vstack(spacing: AppLayout.spacing)
        contentView.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        // Load card
        outer.addArrangedSubview(buildCard(title: "Load User", content: {
            let s = self.vstack()
            s.addArrangedSubview(self.userIdField)
            self.loadBtn.addTarget(self, action: #selector(self.loadTapped), for: .touchUpInside)
            s.addArrangedSubview(self.loadBtn)
            s.addArrangedSubview(self.loadFeedback)
            return s
        }()))

        // Personal
        outer.addArrangedSubview(buildCard(title: "Personal Information", content: {
            let s = self.vstack()
            let dobTap = UITapGestureRecognizer(target: self, action: #selector(self.showDatePicker))
            self.dobField.addGestureRecognizer(dobTap)
            self.dobField.textField.isUserInteractionEnabled = false
            let row = self.hstack()
            row.addArrangedSubview(self.nameField)
            row.addArrangedSubview(self.dobField)
            s.addArrangedSubview(row)
            s.addArrangedSubview(self.genderRadio)
            s.addArrangedSubview(self.maritalRadio)
            return s
        }()))

        // Contact
        outer.addArrangedSubview(buildCard(title: "Contact Information", content: {
            let s = self.vstack()
            let row = self.hstack()
            row.addArrangedSubview(self.emailField)
            row.addArrangedSubview(self.phoneField)
            s.addArrangedSubview(row)
            s.addArrangedSubview(self.nationalityField)
            return s
        }()))

        // Insurance
        outer.addArrangedSubview(buildCard(title: "Insurance Information", content: {
            let s = self.vstack()
            let row = self.hstack()
            row.addArrangedSubview(self.insuranceField)
            row.addArrangedSubview(self.policyField)
            s.addArrangedSubview(row)
            let row2 = self.hstack()
            row2.addArrangedSubview(self.tpaCodeField)
            row2.addArrangedSubview(self.payerNameField)
            s.addArrangedSubview(row2)
            return s
        }()))

        // Medical
        outer.addArrangedSubview(buildCard(title: "Medical Information", content: {
            let s = self.vstack()
            let row = self.hstack()
            row.addArrangedSubview(self.heightField)
            row.addArrangedSubview(self.weightField)
            s.addArrangedSubview(row)
            s.addArrangedSubview(self.bloodTypeRadio)
            s.addArrangedSubview(self.smokerRadio)
            s.addArrangedSubview(self.alcoholicRadio)
            s.addArrangedSubview(self.relationRadio)
            return s
        }()))

        outer.addArrangedSubview(saveFeedback)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        outer.addArrangedSubview(saveBtn)
    }

    private func buildCard(title: String, content: UIStackView) -> UIView {
        let card = AppCardView()
        let stack = vstack()
        card.addSubview(stack)
        stack.addArrangedSubview(SectionTitleLabel(title))
        stack.addArrangedSubview(SectionDivider())
        for v in content.arrangedSubviews { content.removeArrangedSubview(v); stack.addArrangedSubview(v) }
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
        return card
    }

    private func vstack(spacing: CGFloat = AppLayout.spacing) -> UIStackView {
        let s = UIStackView(); s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical; s.spacing = spacing; return s
    }

    private func hstack() -> UIStackView {
        let s = UIStackView(); s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal; s.spacing = 12; s.distribution = .fillEqually; return s
    }

    // MARK: - Load

    @objc private func loadTapped() {
        guard let text = userIdField.text, !text.isEmpty, let id = Int(text) else {
            userIdField.setError("Valid User ID required"); return
        }
        loadBtn.setLoading(true); loadFeedback.hide()
        ApiService.getUser(id: id) { [weak self] user, _, _ in
            DispatchQueue.main.async {
                self?.loadBtn.setLoading(false)
                if let user = user {
                    self?.loadedUserId = user.id
                    self?.prefill(user)
                    self?.loadFeedback.show(message: "Loaded: \(user.name ?? "User #\(id)")", type: .success)
                    self?.saveBtn.isEnabled = true
                    self?.saveBtn.alpha = 1.0
                } else {
                    self?.loadFeedback.show(message: "User not found. Check the ID.", type: .error)
                }
            }
        }
    }

    private func prefill(_ u: User) {
        nameField.text        = u.name
        dobField.text         = u.dateOfBirth
        emailField.text       = u.email
        phoneField.text       = u.phone
        nationalityField.text = u.nationalityNumber
        insuranceField.text   = u.insuranceId
        policyField.text      = u.policyNumber
        tpaCodeField.text     = u.tpaCode
        payerNameField.text   = u.payerName
        heightField.text      = u.height.map { "\($0)" }
        weightField.text      = u.weight.map { "\($0)" }
        if let bt = u.bloodType      { bloodTypeRadio.setSelectedValue(bt) }
        if let s  = u.smoker         { smokerRadio.setSelectedValue(s) }
        if let a  = u.alcoholic      { alcoholicRadio.setSelectedValue(a) }
        if let g  = u.gender         { genderRadio.setSelectedValue(g) }
        if let m  = u.maritalStatus  { maritalRadio.setSelectedValue(m) }
        if let r  = u.relationType   { relationRadio.setSelectedValue(r) }
        if let dobStr = u.dateOfBirth {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
            if let d = f.date(from: dobStr) { selectedDate = d }
        }
    }

    // MARK: - Save

    @objc private func saveTapped() {
        guard let id = loadedUserId else {
            saveFeedback.show(message: "Load a user first.", type: .error); return
        }
        saveBtn.setLoading(true); saveFeedback.hide()
        var updated = User(id: id)
        updated.name              = nameField.text
        updated.email             = emailField.text
        updated.phone             = phoneField.text
        updated.dateOfBirth       = dobField.text
        updated.nationalityNumber = nationalityField.text
        updated.insuranceId       = insuranceField.text
        updated.policyNumber      = policyField.text
        updated.tpaCode           = tpaCodeField.text
        updated.payerName         = payerNameField.text
        updated.height            = Double(heightField.text ?? "")
        updated.weight            = Double(weightField.text ?? "")
        updated.bloodType         = bloodTypeRadio.selectedValue.isEmpty ? nil : bloodTypeRadio.selectedValue
        updated.smoker            = smokerRadio.selectedValue
        updated.alcoholic         = alcoholicRadio.selectedValue
        updated.gender            = genderRadio.selectedValue
        updated.maritalStatus     = maritalRadio.selectedValue
        updated.relationType      = relationRadio.selectedValue

        ApiService.updateUser(id: id, userData: updated) { [weak self] result, _, _ in
            DispatchQueue.main.async {
                self?.saveBtn.setLoading(false)
                if result != nil {
                    self?.saveFeedback.show(message: "User updated successfully.", type: .success)
                } else {
                    self?.saveFeedback.show(message: "Failed to update user. Try again.", type: .error)
                }
            }
        }
    }

    // MARK: - Date Picker

    @objc private func showDatePicker() {
        view.endEditing(true)
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let sheet = UIView()
        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheet.backgroundColor = AppColors.white
        sheet.layer.cornerRadius = 20
        overlay.addSubview(sheet)

        let headerRow = UIStackView()
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        headerRow.axis = .horizontal; headerRow.distribution = .equalSpacing
        sheet.addSubview(headerRow)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(AppColors.gray, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelBtn.addTarget(self, action: #selector(closeDatePicker), for: .touchUpInside)

        let titleLbl = UILabel()
        titleLbl.text = "Select Birth Date"
        titleLbl.font = .systemFont(ofSize: 16, weight: .bold); titleLbl.textColor = AppColors.text

        let confirmBtn = UIButton(type: .system)
        confirmBtn.setTitle("Confirm", for: .normal)
        confirmBtn.setTitleColor(AppColors.primary, for: .normal)
        confirmBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        confirmBtn.addTarget(self, action: #selector(confirmDate), for: .touchUpInside)

        headerRow.addArrangedSubview(cancelBtn)
        headerRow.addArrangedSubview(titleLbl)
        headerRow.addArrangedSubview(confirmBtn)

        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date; picker.maximumDate = Date()
        picker.date = selectedDate
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        sheet.addSubview(picker)

        NSLayoutConstraint.activate([
            sheet.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            headerRow.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 16),
            headerRow.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
            headerRow.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -20),
            picker.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: 10),
            picker.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
            picker.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -20),
            picker.bottomAnchor.constraint(equalTo: sheet.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])

        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        datePickerOverlay = overlay
    }

    @objc private func closeDatePicker() { datePickerOverlay?.removeFromSuperview(); datePickerOverlay = nil }
    @objc private func dateChanged(_ picker: UIDatePicker) { selectedDate = picker.date }
    @objc private func confirmDate() {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        dobField.text = f.string(from: selectedDate)
        closeDatePicker()
    }

    // MARK: - Keyboard

    @objc private func kbShow(_ n: Notification) {
        if let val = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            scrollView.contentInset.bottom = val.cgRectValue.height
        }
    }
    @objc private func kbHide(_ n: Notification) { scrollView.contentInset.bottom = 0 }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false; view.addGestureRecognizer(tap)
    }
}
