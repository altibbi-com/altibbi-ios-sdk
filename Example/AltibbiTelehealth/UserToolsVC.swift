import UIKit
import AltibbiTelehealth

// MARK: - UserToolsVC

class UserToolsVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    private let getUserIdField = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let getUserBtn     = AppButton(title: "Get User", variant: .secondary)
    private let getFeedback    = FeedbackView()

    private let deleteIdField  = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let deleteBtn      = AppButton(title: "Delete User", variant: .danger)
    private let deleteFeedback = FeedbackView()

    private let allUsersBtn    = AppButton(title: "Get All Users", variant: .secondary)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Tools"
        view.backgroundColor = AppColors.background
        setupScrollView()
        setupContent()
        setupKeyboardDismiss()
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        ApiService.getUsers(page: 1, perPage: 1) { [weak self] users, _, _ in
            DispatchQueue.main.async {
                guard let self, let id = users?.first?.id else { return }
                let idStr = "\(id)"
                if self.getUserIdField.text?.isEmpty == false { return }
                self.getUserIdField.text = idStr
                self.deleteIdField.text  = idStr
            }
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

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
        let outer = UIStackView()
        outer.translatesAutoresizingMaskIntoConstraints = false
        outer.axis = .vertical; outer.spacing = AppLayout.spacing
        contentView.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        getUserBtn.addTarget(self, action: #selector(getUserTapped), for: .touchUpInside)
        outer.addArrangedSubview(sectionCard(title: "Get User", views: [getUserIdField, getUserBtn, getFeedback]))

        deleteBtn.addTarget(self, action: #selector(deleteUserTapped), for: .touchUpInside)
        outer.addArrangedSubview(sectionCard(title: "Delete User", views: [deleteIdField, deleteBtn, deleteFeedback]))

        allUsersBtn.addTarget(self, action: #selector(getAllUsersTapped), for: .touchUpInside)
        outer.addArrangedSubview(sectionCard(title: "All Users", views: [allUsersBtn]))
    }

    private func sectionCard(title: String, views: [UIView]) -> UIView {
        let card = AppCardView()
        let stack = UIStackView(); stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical; stack.spacing = AppLayout.spacing
        card.addSubview(stack)
        stack.addArrangedSubview(SectionTitleLabel(title))
        stack.addArrangedSubview(SectionDivider())
        views.forEach { stack.addArrangedSubview($0) }
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
        return card
    }

    // MARK: - Actions

    @objc private func getUserTapped() {
        guard let text = getUserIdField.text, !text.isEmpty, let id = Int(text) else {
            getUserIdField.setError("Valid User ID required"); return
        }
        getUserBtn.setLoading(true); getFeedback.hide()
        ApiService.getUser(id: id) { [weak self] user, _, _ in
            DispatchQueue.main.async {
                self?.getUserBtn.setLoading(false)
                if let user = user {
                    self?.navigationController?.pushViewController(UserDetailVC(user: user), animated: true)
                } else {
                    self?.getFeedback.show(message: "User not found. Check the ID.", type: .error)
                }
            }
        }
    }

    @objc private func deleteUserTapped() {
        guard let text = deleteIdField.text, !text.isEmpty, let id = Int(text) else {
            deleteIdField.setError("Valid User ID required"); return
        }
        showConfirm(title: "Delete User", message: "Are you sure you want to delete user #\(id)?", destructive: "Delete") { [weak self] in
            self?.deleteBtn.setLoading(true); self?.deleteFeedback.hide()
            ApiService.deleteUser(id: id) { _, _, error in
                DispatchQueue.main.async {
                    self?.deleteBtn.setLoading(false)
                    if error == nil {
                        self?.deleteIdField.text = ""
                        self?.deleteFeedback.show(message: "User deleted successfully.", type: .success)
                    } else {
                        self?.deleteFeedback.show(message: "Failed to delete user. Check the ID.", type: .error)
                    }
                }
            }
        }
    }

    @objc private func getAllUsersTapped() {
        navigationController?.pushViewController(UserListVC(), animated: true)
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

// MARK: - UserCell

class UserCell: UITableViewCell {

    private let card       = AppCardView()
    private let nameLabel  = UILabel()
    private let emailLabel = UILabel()
    private let idLabel    = UILabel()
    private let viewBtn    = UIButton(type: .system)
    private let editBtn    = UIButton(type: .system)

    var onView: (() -> Void)?
    var onEdit: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear; selectionStyle = .none; setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal; row.spacing = 12; row.alignment = .center
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        let infoStack = UIStackView()
        infoStack.axis = .vertical; infoStack.spacing = 2
        row.addArrangedSubview(infoStack)

        nameLabel.font  = .systemFont(ofSize: 16, weight: .bold); nameLabel.textColor = AppColors.text
        emailLabel.font = .systemFont(ofSize: 14); emailLabel.textColor = AppColors.gray
        idLabel.font    = .systemFont(ofSize: 13); idLabel.textColor = AppColors.gray
        infoStack.addArrangedSubview(nameLabel)
        infoStack.addArrangedSubview(emailLabel)
        infoStack.addArrangedSubview(idLabel)

        let btnStack = UIStackView()
        btnStack.axis = .horizontal; btnStack.spacing = 8
        row.addArrangedSubview(btnStack)

        for (btn, label, color, sel) in [
            (viewBtn, "View", AppColors.primary,   #selector(viewTapped)),
            (editBtn, "Edit", AppColors.secondary, #selector(editTapped)),
        ] {
            btn.setTitle(label, for: .normal)
            btn.setTitleColor(color, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            btn.backgroundColor = color.withAlphaComponent(0.12)
            btn.layer.cornerRadius = 8
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            btn.addTarget(self, action: sel, for: .touchUpInside)
            btnStack.addArrangedSubview(btn)
        }
    }

    func configure(with user: User) {
        nameLabel.text  = user.name ?? "Unknown"
        emailLabel.text = user.email ?? "-"
        idLabel.text    = "ID: \(user.id ?? 0)"
    }

    @objc private func viewTapped() { onView?() }
    @objc private func editTapped() { onEdit?() }
}

// MARK: - UserListVC

class UserListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView   = UITableView(frame: .zero, style: .plain)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyLabel  = UILabel()
    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Users"
        view.backgroundColor = AppColors.background
        setupTable(); fetchUsers()
    }

    private func setupTable() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = AppColors.primary
        view.addSubview(loadingView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear; tableView.separatorStyle = .none
        tableView.dataSource = self; tableView.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.refreshControl = {
            let rc = UIRefreshControl()
            rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
            return rc
        }()
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No users found."; emptyLabel.textColor = AppColors.gray
        emptyLabel.font = .systemFont(ofSize: 16); emptyLabel.textAlignment = .center; emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchUsers() {
        loadingView.startAnimating(); tableView.isHidden = true; emptyLabel.isHidden = true
        ApiService.getUsers(page: 1, perPage: 50) { [weak self] list, _, _ in
            DispatchQueue.main.async {
                self?.loadingView.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
                self?.users = list ?? []
                self?.tableView.isHidden = false
                self?.emptyLabel.isHidden = !(list?.isEmpty ?? true)
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func refresh() { fetchUsers() }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.configure(with: user)
        cell.onView = { [weak self] in
            self?.navigationController?.pushViewController(UserDetailVC(user: user), animated: true)
        }
        cell.onEdit = { [weak self] in
            self?.navigationController?.pushViewController(EditUserVC(user: user), animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UserDetailVC

class UserDetailVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()
    private var user: User

    init(user: User) { self.user = user; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Details"
        view.backgroundColor = AppColors.background
        setupScroll(); buildContent()
        let editBarBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem = editBarBtn
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let id = user.id { refreshUser(id: id) }
    }

    private func refreshUser(id: Int) {
        ApiService.getUser(id: id) { [weak self] updated, _, _ in
            DispatchQueue.main.async {
                if let u = updated { self?.user = u; self?.rebuildContent() }
            }
        }
    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView); scrollView.addSubview(contentView)
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

    private func buildContent() {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical; stack.spacing = AppLayout.spacing; stack.tag = 99
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])
        populate(stack)
    }

    private func rebuildContent() {
        if let old = contentView.viewWithTag(99) { old.removeFromSuperview() }
        buildContent()
    }

    private func populate(_ stack: UIStackView) {
        let u = user
        stack.addArrangedSubview(AppHeaderView(title: "User Details", subtitle: "ID: \(u.id ?? 0)"))

        stack.addArrangedSubview(infoCard(title: "Personal Information", rows: [
            ("Name",          u.name ?? "-"),
            ("Email",         u.email ?? "-"),
            ("Phone",         u.phone ?? "-"),
            ("Date of Birth", u.dateOfBirth ?? "-"),
            ("Gender",        (u.gender ?? "-").capitalized),
            ("Nationality",   u.nationalityNumber ?? "-"),
        ]))

        stack.addArrangedSubview(infoCard(title: "Insurance & Medical", rows: [
            ("Insurance ID",   u.insuranceId ?? "-"),
            ("Policy Number",  u.policyNumber ?? "-"),
            ("TPA Code",       u.tpaCode ?? "-"),
            ("Payer Name",     u.payerName ?? "-"),
            ("Height",         u.height.map { "\($0) cm" } ?? "-"),
            ("Weight",         u.weight.map { "\($0) kg" } ?? "-"),
            ("Blood Type",     u.bloodType?.uppercased() ?? "-"),
            ("Smoker",         u.smoker == "yes" ? "Yes" : "No"),
            ("Alcoholic",      u.alcoholic == "yes" ? "Yes" : "No"),
            ("Marital Status", (u.maritalStatus ?? "-").capitalized),
            ("Relation Type",  (u.relationType ?? "-").capitalized),
        ]))

        let editBtn = AppButton(title: "Edit Profile")
        editBtn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        stack.addArrangedSubview(editBtn)
    }

    private func infoCard(title: String, rows: [(String, String)]) -> UIView {
        let card = AppCardView()
        let stack = UIStackView(); stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical; stack.spacing = 10; card.addSubview(stack)
        let t = SectionTitleLabel(title); t.textColor = AppColors.primary
        stack.addArrangedSubview(t); stack.addArrangedSubview(SectionDivider())
        for (label, value) in rows { stack.addArrangedSubview(detailRow(label, value)) }
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
        return card
    }

    private func detailRow(_ label: String, _ value: String) -> UIView {
        let row = UIStackView(); row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal; row.spacing = 8
        let l = UILabel(); l.text = label; l.font = .systemFont(ofSize: 14); l.textColor = AppColors.gray
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.addArrangedSubview(l)
        let v = UILabel(); v.text = value.isEmpty ? "-" : value
        v.font = .systemFont(ofSize: 14, weight: .semibold); v.textColor = AppColors.text
        v.textAlignment = .right; v.numberOfLines = 0
        row.addArrangedSubview(v)
        return row
    }

    @objc private func editTapped() {
        navigationController?.pushViewController(EditUserVC(user: user), animated: true)
    }
}

// MARK: - EditUserVC

class EditUserVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()
    private var user: User

    private let nameField         = AppTextFieldView(label: "Name", placeholder: "Full name")
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
    private let genderRadio       = RadioGroupView(title: "Gender", options: ["male", "female"])
    private let maritalRadio      = RadioGroupView(title: "Marital Status", options: ["single", "married", "divorced", "widow"])
    private let relationRadio     = RadioGroupView(title: "Relation Type", options: ["personal", "father", "mother", "sister", "brother", "child", "husband", "wife", "other"])
    private let saveBtn           = AppButton(title: "Save Changes")
    private let feedbackView      = FeedbackView()

    init(user: User) { self.user = user; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit User"
        view.backgroundColor = AppColors.background
        setupScroll(); buildContent(); prefillFields()
        setupKeyboardDismiss()
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func prefillFields() {
        nameField.text        = user.name
        emailField.text       = user.email
        phoneField.text       = user.phone
        nationalityField.text = user.nationalityNumber
        insuranceField.text   = user.insuranceId
        policyField.text      = user.policyNumber
        tpaCodeField.text     = user.tpaCode
        payerNameField.text   = user.payerName
        heightField.text      = user.height.map { "\($0)" }
        weightField.text      = user.weight.map { "\($0)" }
        if let bt = user.bloodType     { bloodTypeRadio.setSelectedValue(bt) }
        if let s  = user.smoker        { smokerRadio.setSelectedValue(s) }
        if let a  = user.alcoholic     { alcoholicRadio.setSelectedValue(a) }
        if let g  = user.gender        { genderRadio.setSelectedValue(g) }
        if let m  = user.maritalStatus { maritalRadio.setSelectedValue(m) }
        if let r  = user.relationType  { relationRadio.setSelectedValue(r) }
    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView); scrollView.addSubview(contentView)
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

    private func buildContent() {
        let outer = UIStackView(); outer.translatesAutoresizingMaskIntoConstraints = false
        outer.axis = .vertical; outer.spacing = AppLayout.spacing
        contentView.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])
        outer.addArrangedSubview(AppHeaderView(title: "Edit User", subtitle: "ID: \(user.id ?? 0)"))
        outer.addArrangedSubview(sectionCard(title: "Personal",   views: [nameField, hrow(emailField, phoneField), genderRadio, maritalRadio]))
        outer.addArrangedSubview(sectionCard(title: "Contact",    views: [nationalityField]))
        outer.addArrangedSubview(sectionCard(title: "Insurance",  views: [hrow(insuranceField, policyField), hrow(tpaCodeField, payerNameField)]))
        outer.addArrangedSubview(sectionCard(title: "Medical",    views: [hrow(heightField, weightField), bloodTypeRadio, smokerRadio, alcoholicRadio, relationRadio]))
        outer.addArrangedSubview(feedbackView)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        outer.addArrangedSubview(saveBtn)
    }

    private func sectionCard(title: String, views: [UIView]) -> UIView {
        let card = AppCardView()
        let stack = UIStackView(); stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical; stack.spacing = AppLayout.spacing
        card.addSubview(stack)
        stack.addArrangedSubview(SectionTitleLabel(title))
        stack.addArrangedSubview(SectionDivider())
        views.forEach { stack.addArrangedSubview($0) }
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
        return card
    }

    private func hrow(_ a: UIView, _ b: UIView) -> UIStackView {
        let s = UIStackView(); s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal; s.spacing = 12; s.distribution = .fillEqually
        s.addArrangedSubview(a); s.addArrangedSubview(b); return s
    }

    @objc private func saveTapped() {
        guard let id = user.id else { return }
        saveBtn.setLoading(true); feedbackView.hide()
        var updated = User(id: id)
        updated.name              = nameField.text
        updated.email             = emailField.text
        updated.phone             = phoneField.text
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
                if let u = result {
                    self?.user = u
                    self?.feedbackView.show(message: "Profile updated successfully.", type: .success)
                } else {
                    self?.feedbackView.show(message: "Failed to update profile. Try again.", type: .error)
                }
            }
        }
    }

    @objc private func kbShow(_ n: Notification) {
        if let v = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            scrollView.contentInset.bottom = v.cgRectValue.height
        }
    }
    @objc private func kbHide(_ n: Notification) { scrollView.contentInset.bottom = 0 }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false; view.addGestureRecognizer(tap)
    }
}
