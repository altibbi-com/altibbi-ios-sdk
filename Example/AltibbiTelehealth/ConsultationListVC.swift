import UIKit
import AltibbiTelehealth

class ConsultationListVC: UIViewController {

    // MARK: - Controls

    private let headerView   = AppHeaderView(title: "My Consultations", subtitle: "Loading user…")
    private let userIdField  = AppTextFieldView(label: "User ID", placeholder: "Enter User ID", keyboardType: .numberPad)
    private let feedbackView = FeedbackView()
    private let loadBtn      = AppButton(title: "Load Consultations", variant: .secondary)
    private let lastBtn      = AppButton(title: "Get Last Consultation", variant: .secondary)

    // MARK: - List

    private let tableView  = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let spinner    = UIActivityIndicatorView(style: .large)

    private var consultations: [Consultation] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Consultations"
        view.backgroundColor = AppColors.background
        setupUI()
        setupKeyboardDismiss()
        fetchMainUserIdAndLoad()
    }

    // MARK: - Layout

    private func setupUI() {
        // Controls card
        let card = AppCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let cardStack = UIStackView()
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = AppLayout.spacing
        card.addSubview(cardStack)

        cardStack.addArrangedSubview(headerView)
        cardStack.addArrangedSubview(SectionDivider())
        cardStack.addArrangedSubview(userIdField)
        cardStack.addArrangedSubview(feedbackView)
        cardStack.addArrangedSubview(loadBtn)
        cardStack.addArrangedSubview(lastBtn)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])

        loadBtn.addTarget(self, action: #selector(loadPressed), for: .touchUpInside)
        lastBtn.addTarget(self, action: #selector(lastPressed), for: .touchUpInside)

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConsultationCell.self, forCellReuseIdentifier: "ConsultationCell")
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.isHidden = true

        // Empty label
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No consultations found."
        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.textColor = AppColors.gray
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        // Spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = AppColors.primary
        spinner.hidesWhenStopped = true

        view.addSubview(card)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppLayout.padding),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppLayout.padding),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppLayout.padding),

            tableView.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 40),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 40),
        ])
    }

    // MARK: - API

    private func fetchMainUserIdAndLoad() {
        headerView.updateSubtitle("Loading user…")
        ApiService.getUsers(page: 1, perPage: 1) { [weak self] users, _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if let id = users?.first?.id {
                    self.userIdField.text = "\(id)"
                    self.headerView.updateSubtitle("User ID: \(id)")
                    self.loadConsultations(showSpinner: true)
                } else {
                    self.headerView.updateSubtitle("No user found")
                    self.feedbackView.show(message: "No users found to auto-fill User ID.", type: .error)
                }
            }
        }
    }

    private func loadConsultations(showSpinner: Bool) {
        guard let text = userIdField.text, let userId = Int(text), userId > 0 else {
            feedbackView.show(message: "User ID missing.", type: .error); return
        }
        feedbackView.hide()
        headerView.updateSubtitle("User ID: \(userId)")
        tableView.isHidden = true
        emptyLabel.isHidden = true
        if showSpinner { spinner.startAnimating() }

        ApiService.getConsultationList(userId: userId, page: 1, perPage: 50) { [weak self] list, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.spinner.stopAnimating()
                if let error {
                    self.feedbackView.show(message: error.localizedDescription, type: .error)
                } else {
                    self.consultations = list ?? []
                    self.tableView.reloadData()
                    let empty = self.consultations.isEmpty
                    self.emptyLabel.isHidden = !empty
                    self.tableView.isHidden  = empty
                }
            }
        }
    }

    private func getLastConsultation() {
        feedbackView.hide()
        ApiService.getLastConsultation { [weak self] consultation, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let c = consultation {
                    if c.status == "new" || c.status == "in_progress" {
                        let waitVC = WaitingVC()
                        waitVC.consultationInfo = c
                        self.navigationController?.pushViewController(waitVC, animated: true)
                    } else {
                        self.feedbackView.show(message: "Last consultation status: \(c.status ?? "unknown")", type: .info)
                    }
                } else {
                    self.feedbackView.show(message: error?.localizedDescription ?? "Failed to fetch last consultation.", type: .error)
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func loadPressed() { loadConsultations(showSpinner: true) }
    @objc private func lastPressed()  { getLastConsultation() }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - UITableViewDataSource

extension ConsultationListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        consultations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConsultationCell", for: indexPath) as! ConsultationCell
        let c = consultations[indexPath.row]
        cell.configure(with: c)
        cell.onViewDetails = { [weak self] in
            guard let self, let id = c.consultationId else { return }
            ApiService.getConsultationInfo(id: id) { result, _, _ in
                DispatchQueue.main.async {
                    if let data = result {
                        self.navigationController?.pushViewController(ConsultationDetailVC(consultation: data), animated: true)
                    }
                }
            }
        }
        cell.onDelete = { [weak self] in
            guard let self, let id = c.consultationId else { return }
            self.showConfirm(title: "Delete Consultation", message: "Delete consultation #\(id)?", destructive: "Delete") {
                ApiService.deleteConsultation(id: id) { [weak self] _, _, _ in
                    DispatchQueue.main.async { self?.loadConsultations(showSpinner: false) }
                }
            }
        }
        return cell
    }
}
