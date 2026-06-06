import UIKit
import AltibbiTelehealth

class FollowUpVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Scroll

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // MARK: - Shared Fields (mirrors FollowUpActivity shared inputs)

    private let userIdField  = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let questionField = AppTextViewField(label: "Question", placeholder: "Follow-up medical question (min 10 chars)…")
    private let parentIdField = AppTextFieldView(label: "Parent Consultation ID", placeholder: "Enter parent consultation ID", keyboardType: .numberPad)

    // MARK: - Follow Up

    private let fuFeedback  = FeedbackView()
    private let fuSubmitBtn = AppButton(title: "Submit Follow Up")

    // MARK: - Scheduled Follow Up

    private let sfuDateField    = AppTextFieldView(label: "Shift Date (yyyy-MM-dd)", placeholder: "Leave empty for today e.g. 2026-03-24")
    private let sfuGetShiftsBtn = AppButton(title: "Get Shifts", variant: .secondary)
    private let sfuShiftField   = AppTextFieldView(label: "Select Shift", placeholder: "Tap 'Get Shifts' first")
    private let sfuFeedback     = FeedbackView()
    private let sfuSubmitBtn    = AppButton(title: "Submit Scheduled Follow Up")
    private let sfuShiftPicker  = UIPickerView()
    private var sfuShiftLabels: [String]  = ["No shift selected"]
    private var sfuShiftValues: [String?] = [nil]

    // MARK: - State

    private var isSubmitting = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Follow Up"
        view.backgroundColor = AppColors.background
        setupScrollView()
        setupContent()
        setupShiftPicker()
        setupKeyboardDismiss()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetForm()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Reset (mirrors onResume → resetForm)

    private func resetForm() {
        questionField.text = ""
        parentIdField.text = ""
        sfuDateField.text  = ""
        fuFeedback.hide()
        sfuFeedback.hide()
        sfuShiftLabels = ["No shift selected"]
        sfuShiftValues = [nil]
        sfuShiftPicker.reloadAllComponents()
        sfuShiftField.text = sfuShiftLabels[0]
        setSubmitting(false)
        fetchMainUserId()
    }

    // MARK: - Auto-fill User ID

    private func fetchMainUserId() {
        ApiService.getUsers(page: 1, perPage: 1) { [weak self] users, _, _ in
            DispatchQueue.main.async {
                guard let self, let id = users?.first?.id else { return }
                self.userIdField.text = "\(id)"
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

    // MARK: - UI

    private func setupContent() {
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .vertical
        outerStack.spacing = AppLayout.spacing
        contentView.addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        outerStack.addArrangedSubview(buildSharedCard())
        outerStack.addArrangedSubview(buildFollowUpCard())
        outerStack.addArrangedSubview(buildScheduledCard())
    }

    private func buildSharedCard() -> UIView {
        let card = AppCardView()
        let stack = makeCardStack()
        card.addSubview(stack)
        pinStack(stack, to: card)
        stack.addArrangedSubview(SectionTitleLabel("Details"))
        stack.addArrangedSubview(SectionDivider())
        stack.addArrangedSubview(userIdField)
        stack.addArrangedSubview(questionField)
        stack.addArrangedSubview(parentIdField)
        return card
    }

    private func buildFollowUpCard() -> UIView {
        let card = AppCardView()
        let stack = makeCardStack()
        card.addSubview(stack)
        pinStack(stack, to: card)
        stack.addArrangedSubview(SectionTitleLabel("Follow Up"))
        stack.addArrangedSubview(SectionDivider())
        stack.addArrangedSubview(fuFeedback)
        stack.addArrangedSubview(fuSubmitBtn)
        fuSubmitBtn.addTarget(self, action: #selector(submitFollowUp), for: .touchUpInside)
        return card
    }

    private func buildScheduledCard() -> UIView {
        let card = AppCardView()
        let stack = makeCardStack()
        card.addSubview(stack)
        pinStack(stack, to: card)
        stack.addArrangedSubview(SectionTitleLabel("Scheduled Follow Up"))
        stack.addArrangedSubview(SectionDivider())
        stack.addArrangedSubview(sfuDateField)
        stack.addArrangedSubview(sfuGetShiftsBtn)
        stack.addArrangedSubview(sfuShiftField)
        stack.addArrangedSubview(sfuFeedback)
        stack.addArrangedSubview(sfuSubmitBtn)
        sfuGetShiftsBtn.addTarget(self, action: #selector(fetchShifts), for: .touchUpInside)
        sfuSubmitBtn.addTarget(self, action: #selector(submitScheduled), for: .touchUpInside)
        return card
    }

    // MARK: - Shift Picker Setup

    private func setupShiftPicker() {
        sfuShiftPicker.dataSource = self
        sfuShiftPicker.delegate   = self
        sfuShiftField.textField.inputView = sfuShiftPicker
        sfuShiftField.textField.tintColor = .clear
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), done], animated: false)
        sfuShiftField.textField.inputAccessoryView = toolbar
        sfuShiftField.text = sfuShiftLabels[0]
    }

    @objc private func dismissPicker() { sfuShiftField.textField.resignFirstResponder() }

    // MARK: - Actions

    private func setSubmitting(_ loading: Bool) {
        isSubmitting = loading
        fuSubmitBtn.setLoading(loading)
        sfuSubmitBtn.setLoading(loading)
    }

    private func validatedInputs() -> (userId: Int, question: String, parentId: Int)? {
        let question = questionField.text ?? ""
        guard question.count >= 10 else {
            fuFeedback.show(message: "Question too short (min 10 chars).", type: .error); return nil
        }
        guard let uidText = userIdField.text, let userId = Int(uidText), userId > 0 else {
            fuFeedback.show(message: "User ID missing.", type: .error); return nil
        }
        guard let cidText = parentIdField.text, let parentId = Int(cidText), parentId > 0 else {
            parentIdField.setError("Required"); return nil
        }
        return (userId, question, parentId)
    }

    @objc private func submitFollowUp() {
        guard !isSubmitting, let (userId, question, parentId) = validatedInputs() else { return }
        fuFeedback.hide()
        setSubmitting(true)

        let c = Consultation(userId: userId, question: question, medium: "chat",
                             mediaIds: nil, parentConsultationId: parentId)
        ApiService.createConsultation(consultation: c, forceWhiteLabelingPartnerName: "partnerTest") { [weak self] result, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setSubmitting(false)
                if error != nil {
                    self.fuFeedback.show(message: "Failed to create follow-up.", type: .error)
                } else {
                    let status = result?.status ?? ""
                    if status == "new" || status == "scheduled" {
                        let waitVC = WaitingVC()
                        waitVC.consultationInfo = result
                        self.navigationController?.pushViewController(waitVC, animated: true)
                    } else {
                        self.fuFeedback.show(message: "Follow-up created (status: \(status)).", type: .success)
                    }
                }
            }
        }
    }

    @objc private func fetchShifts() {
        guard let cidText = parentIdField.text, let parentId = Int(cidText), parentId > 0 else {
            sfuFeedback.show(message: "Enter Parent Consultation ID first.", type: .error); return
        }
        let dateStr = sfuDateField.text?.trimmingCharacters(in: .whitespaces)
        let date    = (dateStr?.isEmpty == false) ? dateStr! : todayDateString()

        sfuGetShiftsBtn.setLoading(true)
        sfuFeedback.hide()

        ApiService.getConsultationAvailableShifts(id: parentId, date: date) { [weak self] result, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.sfuGetShiftsBtn.setLoading(false)
                if error != nil {
                    self.sfuFeedback.show(message: "Failed to get shifts.", type: .error); return
                }
                let shifts = result?.shifts ?? []
                self.sfuShiftLabels.removeAll()
                self.sfuShiftValues.removeAll()
                if shifts.isEmpty {
                    self.sfuShiftLabels = ["No shifts available for \(date)"]
                    self.sfuShiftValues = [nil]
                } else {
                    for s in shifts {
                        self.sfuShiftLabels.append(self.shiftDisplayText(s))
                        self.sfuShiftValues.append(self.shiftValue(from: s))
                    }
                }
                self.sfuShiftPicker.reloadAllComponents()
                self.sfuShiftPicker.selectRow(0, inComponent: 0, animated: false)
                self.sfuShiftField.text = self.sfuShiftLabels[0]
                self.sfuFeedback.show(message: "\(shifts.count) shift(s) loaded.", type: shifts.isEmpty ? .error : .success)
            }
        }
    }

    @objc private func submitScheduled() {
        guard !isSubmitting, let (userId, question, parentId) = validatedInputs() else { return }
        let row = sfuShiftPicker.selectedRow(inComponent: 0)
        guard sfuShiftValues.indices.contains(row), let scheduledTo = sfuShiftValues[row] else {
            sfuFeedback.show(message: "No shift selected. Tap 'Get Shifts' first.", type: .error); return
        }
        sfuFeedback.hide()
        setSubmitting(true)

        let c = Consultation(userId: userId, question: question, medium: "chat",
                             mediaIds: nil, scheduledTo: scheduledTo, parentConsultationId: parentId)
        ApiService.createConsultation(consultation: c, forceWhiteLabelingPartnerName: "partnerTest") { [weak self] _, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setSubmitting(false)
                if error != nil {
                    self.sfuFeedback.show(message: "Failed to schedule follow-up.", type: .error)
                } else {
                    self.sfuFeedback.show(message: "Scheduled follow-up created.", type: .success)
                }
            }
        }
    }

    // MARK: - Shift Helpers

    private func shiftDisplayText(_ s: ConsultationAvailableShift) -> String {
        let start = s.startAt ?? s.startsAt ?? s.from ?? s.value ?? ""
        let end   = s.endAt ?? s.endsAt ?? s.to ?? ""
        let day   = s.day ?? s.fullDate ?? ""
        var parts: [String] = []
        if !day.isEmpty   { parts.append(day) }
        if !start.isEmpty { parts.append(start) }
        if !end.isEmpty   { parts.append("– \(end)") }
        return parts.isEmpty ? (s.value ?? "Shift") : parts.joined(separator: " ")
    }

    private func shiftValue(from s: ConsultationAvailableShift) -> String? {
        for raw in [s.fullDate, s.startAt, s.startsAt, s.value, s.from] {
            if let v = normalizedScheduledTo(raw) { return v }
        }
        return nil
    }

    private func todayDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f.string(from: Date())
    }

    private func normalizedScheduledTo(_ raw: String?) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if raw.contains("-") && raw.contains(":") { return raw }
        if let h = Int(raw), h >= 0, h <= 23 { return String(format: "%@ %02d:00:00", todayDateString(), h) }
        let parts = raw.split(separator: ":").map(String.init)
        if parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]), h >= 0, h <= 23, m >= 0, m <= 59 {
            return String(format: "%@ %02d:%02d:00", todayDateString(), h, m)
        }
        return raw
    }

    // MARK: - UIPickerView

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sfuShiftLabels.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        sfuShiftLabels[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sfuShiftField.text = sfuShiftLabels[row]
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ n: Notification) {
        if let val = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
            scrollView.contentInset.bottom = val.cgRectValue.height
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) { scrollView.contentInset.bottom = 0 }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Helpers

    private func makeCardStack() -> UIStackView {
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
}
