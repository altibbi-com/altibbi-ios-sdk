import UIKit
import AltibbiTelehealth
import MobileCoreServices
import UniformTypeIdentifiers

// MARK: - ConsultationCell

class ConsultationCell: UITableViewCell {

    private let card = AppCardView()
    private let statusBadge   = UILabel()
    private let viewDetailsBtn = UIButton(type: .system)
    private let deleteBtn     = UIButton(type: .system)
    private let doctorLabel   = UILabel()
    private let doctorName    = UILabel()
    private let questionLabel = UILabel()
    private let idLabel       = UILabel()
    private let mediumLabel   = UILabel()
    private let dateLabel     = UILabel()

    var onViewDetails: (() -> Void)?
    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setup()
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

        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .vertical; outerStack.spacing = 10
        card.addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            outerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            outerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            outerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        // Header row
        let headerRow = UIStackView()
        headerRow.axis = .horizontal; headerRow.spacing = 8; headerRow.alignment = .center
        outerStack.addArrangedSubview(headerRow)

        statusBadge.font = .systemFont(ofSize: 11, weight: .black)
        statusBadge.layer.cornerRadius = 8; statusBadge.clipsToBounds = true
        statusBadge.textAlignment = .center
        NSLayoutConstraint.activate([statusBadge.heightAnchor.constraint(equalToConstant: 24)])
        headerRow.addArrangedSubview(statusBadge)

        let spacer = UIView(); spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerRow.addArrangedSubview(spacer)

        viewDetailsBtn.setTitle("View Details", for: .normal)
        viewDetailsBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        viewDetailsBtn.setTitleColor(AppColors.primary, for: .normal)
        viewDetailsBtn.backgroundColor = AppColors.primary.withAlphaComponent(0.1)
        viewDetailsBtn.layer.cornerRadius = 6
        viewDetailsBtn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        viewDetailsBtn.addTarget(self, action: #selector(viewDetailsTapped), for: .touchUpInside)
        headerRow.addArrangedSubview(viewDetailsBtn)

        deleteBtn.setTitle("Delete", for: .normal)
        deleteBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        deleteBtn.setTitleColor(AppColors.error, for: .normal)
        deleteBtn.backgroundColor = AppColors.error.withAlphaComponent(0.1)
        deleteBtn.layer.cornerRadius = 6
        deleteBtn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        headerRow.addArrangedSubview(deleteBtn)

        // Doctor row
        let doctorRow = UIStackView()
        doctorRow.axis = .horizontal; doctorRow.spacing = 4; doctorRow.alignment = .center
        outerStack.addArrangedSubview(doctorRow)

        doctorLabel.text = "Doctor:"
        doctorLabel.font = .systemFont(ofSize: 12); doctorLabel.textColor = AppColors.gray
        doctorRow.addArrangedSubview(doctorLabel)

        doctorName.font = .systemFont(ofSize: 13, weight: .bold); doctorName.textColor = AppColors.text
        doctorRow.addArrangedSubview(doctorName)
        doctorRow.addArrangedSubview(UIView())

        // Question
        questionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        questionLabel.textColor = AppColors.text; questionLabel.numberOfLines = 2
        outerStack.addArrangedSubview(questionLabel)

        // Footer
        let footerDiv = SectionDivider()
        outerStack.addArrangedSubview(footerDiv)

        let footerRow = UIStackView()
        footerRow.axis = .horizontal; footerRow.distribution = .fillEqually
        outerStack.addArrangedSubview(footerRow)

        for lbl in [idLabel, mediumLabel, dateLabel] {
            lbl.font = .systemFont(ofSize: 12); lbl.textColor = AppColors.gray
            footerRow.addArrangedSubview(lbl)
        }
        mediumLabel.textAlignment = .center
        dateLabel.textAlignment   = .right
    }

    func configure(with c: Consultation) {
        let status = c.status ?? "unknown"
        statusBadge.text = "  \(status.uppercased())  "
        let statusColor = statusColor(for: status)
        statusBadge.backgroundColor = statusColor.withAlphaComponent(0.15)
        statusBadge.textColor = statusColor

        doctorName.text    = c.doctorName ?? "Generic Doctor"
        questionLabel.text = c.question

        let id = c.consultationId.map { "\($0)" } ?? "-"
        idLabel.text     = "ID: \(id)"
        mediumLabel.text = (c.medium).uppercased()

        if let createdAt = c.createdAt {
            let df = ISO8601DateFormatter()
            df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = df.date(from: createdAt) {
                let display = DateFormatter()
                display.dateStyle = .short
                dateLabel.text = display.string(from: date)
            } else {
                dateLabel.text = String(createdAt.prefix(10))
            }
        } else {
            dateLabel.text = "-"
        }
    }

    private func statusColor(for status: String) -> UIColor {
        switch status.lowercased() {
        case "closed":      return AppColors.gray
        case "in_progress": return AppColors.primary
        case "new":         return AppColors.secondary
        default:            return AppColors.text
        }
    }

    @objc private func viewDetailsTapped() { onViewDetails?() }
    @objc private func deleteTapped()      { onDelete?() }
}

// MARK: - ConsultationDetailVC

class ConsultationDetailVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()
    private var consultation: Consultation

    init(consultation: Consultation) {
        self.consultation = consultation
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consultation Details"
        view.backgroundColor = AppColors.background
        setupScrollView()
        buildContent()
    }

    private func setupScrollView() {
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
        let c = consultation
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .vertical; outerStack.spacing = AppLayout.spacing
        contentView.addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            outerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            outerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            outerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        let idStr = c.consultationId.map { "\($0)" } ?? "-"
        outerStack.addArrangedSubview(AppHeaderView(title: "Consultation Details", subtitle: "ID: \(idStr)"))

        // General Info
        let generalCard = infoCard(title: "General Information", rows: [
            ("Status",    (c.status ?? "-").uppercased()),
            ("Medium",    (c.medium).uppercased()),
            ("Created",   c.createdAt.map { String($0.prefix(10)) } ?? "-"),
            ("Closed",    c.closedAt.map { String($0.prefix(10)) } ?? "-"),
            ("Doctor",    c.doctorName ?? "Generic Doctor"),
        ])
        outerStack.addArrangedSubview(generalCard)

        // Question
        let qCard = AppCardView()
        let qStack = vstack(); qCard.addSubview(qStack); pin(qStack, to: qCard)
        let qTitle = SectionTitleLabel("Question")
        qTitle.textColor = AppColors.primary
        qStack.addArrangedSubview(qTitle)
        qStack.addArrangedSubview(SectionDivider())
        let qText = UILabel()
        qText.text = c.question; qText.font = .italicSystemFont(ofSize: 15)
        qText.textColor = AppColors.text; qText.numberOfLines = 0
        qStack.addArrangedSubview(qText)
        outerStack.addArrangedSubview(qCard)

        // User Info
        if let u = c.user {
            outerStack.addArrangedSubview(infoCard(title: "User Information", rows: [
                ("Name",          u.name ?? "-"),
                ("Phone",         u.nationalityNumber ?? "-"),
                ("Gender",        (u.gender ?? "-").capitalized),
                ("Date of Birth", u.dateOfBirth ?? "-"),
                ("Insurance ID",  u.insuranceId ?? "-"),
                ("Policy Number", u.policyNumber ?? "-"),
                ("TPA Code",      u.tpaCode ?? "-"),
                ("Payer Name",    u.payerName ?? "-"),
            ]))
        }

        // Recommendation
        if let rec = c.recommendation?.data {
            outerStack.addArrangedSubview(buildRecommendationCard(rec))
        }
    }

    private func infoCard(title: String, rows: [(String, String)]) -> UIView {
        let card = AppCardView()
        let stack = vstack(); card.addSubview(stack); pin(stack, to: card)
        let titleLbl = SectionTitleLabel(title)
        titleLbl.textColor = AppColors.primary
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(SectionDivider())
        for (label, value) in rows {
            stack.addArrangedSubview(detailRow(label: label, value: value))
        }
        return card
    }

    private func buildRecommendationCard(_ data: RecommendationData) -> UIView {
        let card = AppCardView()
        let stack = vstack(); card.addSubview(stack); pin(stack, to: card)
        let titleLbl = SectionTitleLabel("Recommendation")
        titleLbl.textColor = AppColors.primary
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(SectionDivider())

        // ICD10
        if let icd = data.icd10 {
            if let diagnoses = icd.diagnosis, !diagnoses.isEmpty {
                stack.addArrangedSubview(subSectionTitle("Diagnoses"))
                for d in diagnoses {
                    let text = [d.name, d.code.map { "(\($0))" }].compactMap { $0 }.joined(separator: " ")
                    stack.addArrangedSubview(detailRow(label: "Diagnosis", value: text))
                }
            }
            if let symptoms = icd.symptom, !symptoms.isEmpty {
                stack.addArrangedSubview(subSectionTitle("Symptoms"))
                for s in symptoms {
                    let text = [s.name, s.code.map { "(\($0))" }].compactMap { $0 }.joined(separator: " ")
                    stack.addArrangedSubview(detailRow(label: "Symptom", value: text))
                }
            }
        }

        // Drugs
        if let drugs = data.drug?.fdaDrug, !drugs.isEmpty {
            stack.addArrangedSubview(subSectionTitle("Medications"))
            for drug in drugs {
                stack.addArrangedSubview(buildDrugView(drug))
            }
        }

        // Lab
        if let lab = data.lab {
            let labItems = (lab.lab ?? []).map { $0.name ?? "" }
            let panelItems = (lab.panel ?? []).map { $0.name ?? "" }
            if !labItems.isEmpty || !panelItems.isEmpty {
                stack.addArrangedSubview(subSectionTitle("Laboratory Tests"))
                for name in labItems { stack.addArrangedSubview(detailRow(label: "Lab Test", value: name)) }
                for name in panelItems { stack.addArrangedSubview(detailRow(label: "Panel", value: name)) }
            }
        }

        // Follow-up
        if let followUps = data.followUp, !followUps.isEmpty {
            stack.addArrangedSubview(subSectionTitle("Follow Up Instructions"))
            for f in followUps {
                if let name = f.name { stack.addArrangedSubview(detailRow(label: "Instruction", value: name)) }
            }
        }

        // Referral
        if let referral = data.doctorReferral {
            stack.addArrangedSubview(subSectionTitle("Referral"))
            stack.addArrangedSubview(detailRow(label: "Specialist", value: referral.name ?? "-"))
        }

        return card
    }

    private func buildDrugView(_ drug: RecommendationFdaDrug) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(hex: "#F8F9FA")
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(hex: "#E9ECEF").cgColor

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical; stack.spacing = 6
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])

        let nameParts = [drug.name, drug.tradeName.map { "(\($0))" }].compactMap { $0 }.joined(separator: " ")
        let nameLabel = UILabel()
        nameLabel.text = nameParts; nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        nameLabel.textColor = AppColors.primary; nameLabel.numberOfLines = 0
        stack.addArrangedSubview(nameLabel)

        let gridStack = UIStackView()
        gridStack.axis = .horizontal; gridStack.distribution = .fillEqually; gridStack.spacing = 8
        stack.addArrangedSubview(gridStack)

        let leftCol = UIStackView(); leftCol.axis = .vertical; leftCol.spacing = 4
        let rightCol = UIStackView(); rightCol.axis = .vertical; rightCol.spacing = 4
        gridStack.addArrangedSubview(leftCol); gridStack.addArrangedSubview(rightCol)

        func addField(_ label: String, _ value: String?, to col: UIStackView) {
            guard let value = value, !value.isEmpty else { return }
            let lbl = UILabel()
            lbl.text = "\(label): \(value)"
            lbl.font = .systemFont(ofSize: 12); lbl.textColor = AppColors.text; lbl.numberOfLines = 0
            col.addArrangedSubview(lbl)
        }

        addField("Dosage", drug.dosage, to: leftCol)
        addField("Frequency", drug.frequency, to: rightCol)
        addField("Duration", drug.duration.map { "\($0) days" }, to: leftCol)
        addField("Route", drug.routeOfAdministration, to: rightCol)

        for (text, val) in [("How to use", drug.howToUse), ("Food relation", drug.relationWithFood), ("Instructions", drug.specialInstructions)] {
            if let val = val, !val.isEmpty {
                let lbl = UILabel()
                lbl.text = "\(text): \(val)"; lbl.font = .systemFont(ofSize: 12)
                lbl.textColor = AppColors.text; lbl.numberOfLines = 0
                stack.addArrangedSubview(lbl)
            }
        }
        return container
    }

    // MARK: Helpers

    private func detailRow(label: String, value: String) -> UIView {
        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal; row.spacing = 8; row.alignment = .top

        let lbl = UILabel()
        lbl.text = label; lbl.font = .systemFont(ofSize: 14); lbl.textColor = AppColors.gray
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.addArrangedSubview(lbl)

        let val = UILabel()
        val.text = value.isEmpty ? "-" : value
        val.font = .systemFont(ofSize: 14, weight: .semibold); val.textColor = AppColors.text
        val.textAlignment = .right; val.numberOfLines = 0
        row.addArrangedSubview(val)
        return row
    }

    private func subSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = text; lbl.font = .systemFont(ofSize: 16, weight: .semibold); lbl.textColor = AppColors.text
        return lbl
    }

    private func vstack() -> UIStackView {
        let s = UIStackView(); s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical; s.spacing = AppLayout.spacing; return s
    }

    private func pin(_ stack: UIView, to card: UIView) {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
    }
}

// MARK: - Sina Message Cells

private class SinaUserCell: UITableViewCell {
    private let bubbleView    = UIView()
    private let messageLabel  = UILabel()
    private let timeLabel     = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear; selectionStyle = .none
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = AppColors.primary
        bubbleView.layer.cornerRadius = 18
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .natural
        bubbleView.addSubview(messageLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = AppColors.gray
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        bubbleView.layer.maskedCorners = isRTL
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

    func configure(text: String, time: String) {
        let style = NSMutableParagraphStyle(); style.lineSpacing = 2
        messageLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: style,
                         .font: UIFont.systemFont(ofSize: 16),
                         .foregroundColor: UIColor.white]
        )
        timeLabel.text = time
    }
}

private class SinaAICell: UITableViewCell {
    private let avatarBg     = UIView()
    private let avatarImg    = UIImageView()
    private let bubbleView   = UIView()
    private let messageLabel = UILabel()
    private let linkLabel    = UILabel()
    private let timeLabel    = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear; selectionStyle = .none

        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.backgroundColor = .white
        avatarBg.layer.cornerRadius = 16
        avatarBg.applyShadow(opacity: 0.1, radius: 2, offset: CGSize(width: 0, height: 1))
        contentView.addSubview(avatarBg)

        avatarImg.translatesAutoresizingMaskIntoConstraints = false
        avatarImg.image = UIImage(named: "master_logo")
        avatarImg.contentMode = .scaleAspectFit
        avatarBg.addSubview(avatarImg)

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = .white
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.borderWidth = 1
        bubbleView.layer.borderColor = AppColors.lightGray.cgColor
        contentView.addSubview(bubbleView)

        let inner = UIStackView(); inner.translatesAutoresizingMaskIntoConstraints = false
        inner.axis = .vertical; inner.spacing = 6
        bubbleView.addSubview(inner)

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textColor = AppColors.text
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .natural
        inner.addArrangedSubview(messageLabel)

        linkLabel.font = .systemFont(ofSize: 12)
        linkLabel.textColor = AppColors.primary
        linkLabel.numberOfLines = 0
        linkLabel.textAlignment = .natural
        linkLabel.isHidden = true
        inner.addArrangedSubview(linkLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = AppColors.gray
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            avatarBg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarBg.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            avatarBg.widthAnchor.constraint(equalToConstant: 32),
            avatarBg.heightAnchor.constraint(equalToConstant: 32),
            avatarImg.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            avatarImg.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),
            avatarImg.widthAnchor.constraint(equalToConstant: 22),
            avatarImg.heightAnchor.constraint(equalToConstant: 22),

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 8),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
            inner.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            inner.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            inner.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            inner.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),

            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        bubbleView.layer.maskedCorners = isRTL
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }

    func configure(text: String, time: String, message: SinaMessage? = nil) {
        messageLabel.attributedText = SinaMarkdown.render(text, baseFont: .systemFont(ofSize: 15), textColor: AppColors.text)
        if let links = message?.data?.links, !links.isEmpty {
            linkLabel.isHidden = false
            linkLabel.text = links.compactMap { l in
                guard let brief = l.brief, let url = l.url else { return nil }
                return "• \(brief): \(url)"
            }.joined(separator: "\n")
        } else {
            linkLabel.isHidden = true
        }
        timeLabel.text = time
    }
}

// MARK: - SinaMarkdown

enum SinaMarkdown {

    static func render(_ source: String, baseFont: UIFont, textColor: UIColor) -> NSAttributedString {
        let normalized = source.replacingOccurrences(of: "\\n", with: "\n")
        let result = NSMutableAttributedString()
        let lines  = normalized.components(separatedBy: "\n")

        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 3; paraStyle.paragraphSpacing = 4
        paraStyle.alignment = .natural; paraStyle.baseWritingDirection = .natural

        for (idx, raw) in lines.enumerated() {
            var line = raw
            var font = baseFont

            if line.hasPrefix("### ")      { line = String(line.dropFirst(4)); font = .boldSystemFont(ofSize: baseFont.pointSize + 1) }
            else if line.hasPrefix("## ")  { line = String(line.dropFirst(3)); font = .boldSystemFont(ofSize: baseFont.pointSize + 2) }
            else if line.hasPrefix("# ")   { line = String(line.dropFirst(2)); font = .boldSystemFont(ofSize: baseFont.pointSize + 4) }

            if line.hasPrefix("- ") || line.hasPrefix("* ") { line = "• " + String(line.dropFirst(2)) }

            let baseAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor, .paragraphStyle: paraStyle]
            result.append(renderInline(line, attrs: baseAttrs))
            if idx < lines.count - 1 { result.append(NSAttributedString(string: "\n", attributes: baseAttrs)) }
        }
        return result
    }

    private static func renderInline(_ text: String, attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text, attributes: attrs)
        applyPattern(result, pattern: #"\*\*(.+?)\*\*"#) { font in
            let desc = font.fontDescriptor.withSymbolicTraits([.traitBold]) ?? font.fontDescriptor
            return UIFont(descriptor: desc, size: font.pointSize)
        }
        applyPattern(result, pattern: #"(?<!\*)\*([^*\n]+?)\*(?!\*)"#) { font in
            let desc = font.fontDescriptor.withSymbolicTraits([.traitItalic]) ?? font.fontDescriptor
            return UIFont(descriptor: desc, size: font.pointSize)
        }
        return result
    }

    private static func applyPattern(_ attr: NSMutableAttributedString, pattern: String, transform: (UIFont) -> UIFont) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return }
        var location = 0
        while location < attr.length {
            let searchRange = NSRange(location: location, length: attr.length - location)
            guard let m = regex.firstMatch(in: attr.string, options: [], range: searchRange) else { break }
            let outer = m.range; let inner = m.range(at: 1)
            let innerCopy = NSMutableAttributedString(attributedString: attr.attributedSubstring(from: inner))
            innerCopy.enumerateAttribute(.font, in: NSRange(location: 0, length: innerCopy.length), options: []) { val, r, _ in
                if let f = val as? UIFont { innerCopy.addAttribute(.font, value: transform(f), range: r) }
            }
            attr.replaceCharacters(in: outer, with: innerCopy)
            location = outer.location + innerCopy.length
        }
    }
}

// MARK: - AskSinaVC

struct SinaChatEntry {
    enum Sender { case user, ai }
    var sender: Sender
    var text: String
    var time: String
    var aiMessage: SinaMessage?
}

private let SinaSuggestions = [
    "عندي صداع",
    "معدتي تؤلمني",
    "عندي حرارة",
    "قلبي ينبض ببطء",
    "نصائح لنمط الحياة",
    "نصائح صحية"
]

class AskSinaVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var initialSessionId: String?

    private var sessionId: String?
    private var entries: [SinaChatEntry] = []
    private var isTyping = false
    private var isAttaching = false
    private var typewriterTimer: Timer?

    // Header
    private let headerCard = UIView()
    private let backBtn = UIButton(type: .system)
    private let avatarBg = UIView()
    private let avatarImg = UIImageView()
    private let titleLbl = UILabel()
    private let subtitleLbl = UILabel()
    private let endBtn = UIButton(type: .system)

    private let tableView          = UITableView()
    private let loadingIndicator   = UIActivityIndicatorView(style: .medium)
    private let emptyLabel         = UILabel()

    // Typing row
    private let typingRow = UIView()
    private let typingSpinner = UIActivityIndicatorView(style: .medium)
    private let typingLbl = UILabel()

    // Suggestions
    private let suggestionsScroll = UIScrollView()
    private let suggestionsStack = UIStackView()

    // Input
    private let inputBar           = UIView()
    private let inputBarFiller     = UIView()
    private let inputTopBorder     = UIView()
    private let msgField           = UITextField()
    private let sendBtn            = UIButton(type: .system)
    private let attachBtn          = UIButton(type: .system)

    private var inputBarBottomConstraint: NSLayoutConstraint!

    private static let askSinaBg = UIColor(hex: "#F8F9FE")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.semanticContentAttribute = .forceRightToLeft
        view.backgroundColor = AskSinaVC.askSinaBg
        setupHeader()
        setupTableView()
        setupTypingRow()
        setupSuggestions()
        setupInputBar()
        setupEmptyState()
        registerKeyboardNotifications()
        if let sid = initialSessionId {
            sessionId = sid
            loadHistory(sid)
        } else {
            startNewSession()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.removeObserver(self)
        typewriterTimer?.invalidate()
    }

    // MARK: - Header

    private func setupHeader() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.backgroundColor = AskSinaVC.askSinaBg
        view.addSubview(headerCard)

        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = AppColors.text
        backBtn.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        headerCard.addSubview(backBtn)

        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.backgroundColor = .white
        avatarBg.layer.cornerRadius = 18
        avatarBg.applyShadow(opacity: 0.1, radius: 2, offset: CGSize(width: 0, height: 1))
        headerCard.addSubview(avatarBg)

        avatarImg.translatesAutoresizingMaskIntoConstraints = false
        avatarImg.image = UIImage(named: "master_logo")
        avatarImg.contentMode = .scaleAspectFit
        avatarBg.addSubview(avatarImg)

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 0
        headerCard.addSubview(textStack)

        titleLbl.text = "سينا"
        titleLbl.font = .systemFont(ofSize: 16, weight: .bold)
        titleLbl.textColor = AppColors.text
        textStack.addArrangedSubview(titleLbl)

        subtitleLbl.text = "مساعد صحي ذكي"
        subtitleLbl.font = .systemFont(ofSize: 12)
        subtitleLbl.textColor = AppColors.gray
        textStack.addArrangedSubview(subtitleLbl)

        endBtn.translatesAutoresizingMaskIntoConstraints = false
        endBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        endBtn.tintColor = AppColors.text
        endBtn.addTarget(self, action: #selector(endSessionPressed), for: .touchUpInside)
        headerCard.addSubview(endBtn)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backBtn.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 12),
            backBtn.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),

            avatarBg.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 4),
            avatarBg.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            avatarBg.widthAnchor.constraint(equalToConstant: 36),
            avatarBg.heightAnchor.constraint(equalToConstant: 36),
            avatarImg.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            avatarImg.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),
            avatarImg.widthAnchor.constraint(equalToConstant: 24),
            avatarImg.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: endBtn.leadingAnchor, constant: -8),

            endBtn.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -12),
            endBtn.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            endBtn.widthAnchor.constraint(equalToConstant: 40),
            endBtn.heightAnchor.constraint(equalToConstant: 40),

            headerCard.bottomAnchor.constraint(equalTo: avatarBg.bottomAnchor, constant: 8),
            avatarBg.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 8),
        ])
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func endSessionPressed() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "محادثة جديدة", style: .default) { [weak self] _ in self?.startNewSession() })
        sheet.addAction(UIAlertAction(title: "إنهاء الجلسة", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        sheet.addAction(UIAlertAction(title: "إلغاء", style: .cancel))
        if let pop = sheet.popoverPresentationController { pop.sourceView = endBtn; pop.sourceRect = endBtn.bounds }
        present(sheet, animated: true)
    }

    // MARK: - Table

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AskSinaVC.askSinaBg
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension; tableView.estimatedRowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(SinaUserCell.self, forCellReuseIdentifier: "SinaUserCell")
        tableView.register(SinaAICell.self,   forCellReuseIdentifier: "SinaAICell")
        view.addSubview(tableView)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true; loadingIndicator.color = AppColors.primary
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Typing row

    private func setupTypingRow() {
        typingRow.translatesAutoresizingMaskIntoConstraints = false
        typingRow.backgroundColor = AskSinaVC.askSinaBg
        typingRow.isHidden = true
        view.addSubview(typingRow)

        typingSpinner.translatesAutoresizingMaskIntoConstraints = false
        typingSpinner.color = AppColors.primary
        typingSpinner.startAnimating()
        typingRow.addSubview(typingSpinner)

        typingLbl.translatesAutoresizingMaskIntoConstraints = false
        typingLbl.text = "سينا يكتب…"
        typingLbl.font = .systemFont(ofSize: 12)
        typingLbl.textColor = AppColors.gray
        typingRow.addSubview(typingLbl)

        NSLayoutConstraint.activate([
            typingRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            typingRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            typingRow.topAnchor.constraint(equalTo: tableView.bottomAnchor),

            typingSpinner.leadingAnchor.constraint(equalTo: typingRow.leadingAnchor, constant: 20),
            typingSpinner.centerYAnchor.constraint(equalTo: typingRow.centerYAnchor),
            typingSpinner.widthAnchor.constraint(equalToConstant: 18),
            typingSpinner.heightAnchor.constraint(equalToConstant: 18),

            typingLbl.leadingAnchor.constraint(equalTo: typingSpinner.trailingAnchor, constant: 8),
            typingLbl.centerYAnchor.constraint(equalTo: typingRow.centerYAnchor),
            typingLbl.topAnchor.constraint(equalTo: typingRow.topAnchor, constant: 4),
            typingLbl.bottomAnchor.constraint(equalTo: typingRow.bottomAnchor, constant: -4),
        ])
    }

    // MARK: - Suggestions

    private func setupSuggestions() {
        suggestionsScroll.translatesAutoresizingMaskIntoConstraints = false
        suggestionsScroll.backgroundColor = AskSinaVC.askSinaBg
        suggestionsScroll.showsHorizontalScrollIndicator = false
        suggestionsScroll.semanticContentAttribute = .forceRightToLeft
        view.addSubview(suggestionsScroll)

        suggestionsStack.translatesAutoresizingMaskIntoConstraints = false
        suggestionsStack.axis = .horizontal
        suggestionsStack.spacing = 8
        suggestionsStack.semanticContentAttribute = .forceRightToLeft
        suggestionsScroll.addSubview(suggestionsStack)

        for suggestion in SinaSuggestions {
            suggestionsStack.addArrangedSubview(makeChip(suggestion))
        }

        NSLayoutConstraint.activate([
            suggestionsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsScroll.topAnchor.constraint(equalTo: typingRow.bottomAnchor),
            suggestionsScroll.heightAnchor.constraint(equalToConstant: 44),

            suggestionsStack.topAnchor.constraint(equalTo: suggestionsScroll.topAnchor, constant: 6),
            suggestionsStack.bottomAnchor.constraint(equalTo: suggestionsScroll.bottomAnchor, constant: -6),
            suggestionsStack.leadingAnchor.constraint(equalTo: suggestionsScroll.leadingAnchor, constant: 12),
            suggestionsStack.trailingAnchor.constraint(equalTo: suggestionsScroll.trailingAnchor, constant: -12),
        ])
    }

    private func makeChip(_ text: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(AppColors.text, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = AppColors.lightGray.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        msgField.text = sender.title(for: .normal)
        refreshSendEnabled()
    }

    private func updateSuggestionsVisibility() {
        suggestionsScroll.isHidden = !entries.isEmpty
    }

    // MARK: - Input bar

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

        attachBtn.translatesAutoresizingMaskIntoConstraints = false
        attachBtn.setTitle("📎", for: .normal)
        attachBtn.titleLabel?.font = .systemFont(ofSize: 20)
        attachBtn.addTarget(self, action: #selector(presentAttachmentMenu), for: .touchUpInside)
        inputBar.addSubview(attachBtn)

        msgField.translatesAutoresizingMaskIntoConstraints = false
        msgField.placeholder = "اسأل أي شيء…"
        msgField.font = .systemFont(ofSize: 15)
        msgField.textColor = AppColors.text
        msgField.borderStyle = .none
        msgField.backgroundColor = .white
        msgField.layer.cornerRadius = 8
        msgField.layer.borderWidth = 1
        msgField.layer.borderColor = AppColors.lightGray.cgColor
        msgField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        msgField.leftViewMode = .always
        msgField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        msgField.rightViewMode = .always
        msgField.textAlignment = .natural
        msgField.semanticContentAttribute = .forceRightToLeft
        msgField.returnKeyType = .send
        msgField.delegate = self
        msgField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        inputBar.addSubview(msgField)

        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitle("→", for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        sendBtn.backgroundColor = AppColors.primary
        sendBtn.layer.cornerRadius = 24
        sendBtn.clipsToBounds = true
        sendBtn.isEnabled = false
        sendBtn.alpha = 0.5
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputBar.addSubview(sendBtn)

        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            suggestionsScroll.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

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

            attachBtn.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 8),
            attachBtn.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            attachBtn.widthAnchor.constraint(equalToConstant: 48),
            attachBtn.heightAnchor.constraint(equalToConstant: 48),

            msgField.leadingAnchor.constraint(equalTo: attachBtn.trailingAnchor, constant: 4),
            msgField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            msgField.heightAnchor.constraint(equalToConstant: 48),

            sendBtn.leadingAnchor.constraint(equalTo: msgField.trailingAnchor, constant: 8),
            sendBtn.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -8),
            sendBtn.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendBtn.widthAnchor.constraint(equalToConstant: 48),
            sendBtn.heightAnchor.constraint(equalToConstant: 48),

            inputBar.topAnchor.constraint(equalTo: msgField.topAnchor, constant: -8),
        ])
    }

    private func setupEmptyState() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "🤖  اسأل سينا أسئلتك الصحية"
        emptyLabel.font = .systemFont(ofSize: 15); emptyLabel.textColor = AppColors.gray
        emptyLabel.textAlignment = .center; emptyLabel.numberOfLines = 0
        tableView.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -40),
        ])
    }

    // MARK: - Keyboard

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame    = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let h = frame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) { self.inputBarBottomConstraint.constant = -h; self.view.layoutIfNeeded() }
        scrollToBottom()
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) { self.inputBarBottomConstraint.constant = 0; self.view.layoutIfNeeded() }
    }

    // MARK: - Session

    @objc func startNewSession() {
        guard AltibbiService.sinaEndpoint != nil else {
            showAlert(title: "غير مهيأ", message: "لم يتم تعيين رابط سينا. أدخل الرابط في شاشة تسجيل الدخول وأعد تهيئة SDK.")
            return
        }
        typewriterTimer?.invalidate()
        sessionId = nil; entries = []; tableView.reloadData()
        updateSuggestionsVisibility()
        emptyLabel.isHidden = false; loadingIndicator.startAnimating(); msgField.isEnabled = false
        ApiService.createSinaSession { [weak self] session, _, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating(); self?.msgField.isEnabled = true
                if let error = error {
                    self?.showAlert(title: "خطأ", message: error.localizedDescription)
                } else if let sid = session?.id {
                    self?.sessionId = sid
                    self?.loadHistory(sid)
                } else {
                    self?.showAlert(title: "خطأ", message: "فشل إنشاء جلسة سينا.")
                }
            }
        }
    }

    private func loadHistory(_ sid: String) {
        ApiService.getSinaChatMessages(sessionId: sid, page: 1, perPage: 50) { [weak self] messages, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let msgs = messages, !msgs.isEmpty {
                    let items: [SinaChatEntry] = msgs.reversed().map { m in
                        let sender: SinaChatEntry.Sender = (m.sender == "sina" || m.sender == "ai") ? .ai : .user
                        return SinaChatEntry(sender: sender, text: m.text ?? "",
                                             time: self.formatTime(m.createdAt),
                                             aiMessage: sender == .ai ? m : nil)
                    }
                    self.entries = items
                } else {
                    self.entries = [SinaChatEntry(sender: .ai,
                                                  text: "مرحبًا! أنا سينا، مساعدك الصحي الذكي. كيف يمكنني مساعدتك اليوم؟",
                                                  time: self.formatTime(nil), aiMessage: nil)]
                }
                self.tableView.reloadData()
                self.scrollToBottom()
                self.updateSuggestionsVisibility()
                self.emptyLabel.isHidden = !self.entries.isEmpty
            }
        }
    }

    // MARK: - Send

    @objc private func textChanged() { refreshSendEnabled() }

    private func refreshSendEnabled() {
        let hasText = !(msgField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        let enabled = hasText && !isTyping && !isAttaching
        sendBtn.isEnabled = enabled
        sendBtn.alpha = enabled ? 1.0 : 0.5
    }

    @objc private func sendMessage() {
        let text = (msgField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let sessionId = sessionId, !isTyping, !isAttaching else { return }
        msgField.text = ""
        refreshSendEnabled()

        entries.append(SinaChatEntry(sender: .user, text: text, time: formatTime(nil), aiMessage: nil))
        tableView.reloadData(); scrollToBottom(); updateSuggestionsVisibility(); emptyLabel.isHidden = true

        setTyping(true)
        ApiService.sendSinaMessage(sessionId: sessionId, text: text, mediaId: nil) { [weak self] response, _, error in
            DispatchQueue.main.async {
                self?.setTyping(false)
                guard let self = self else { return }
                if error != nil {
                    self.appendSinaMessage("عذرًا، لم أتمكن من المعالجة. حاول مرة أخرى.", time: self.formatTime(nil))
                    return
                }
                let aiText = response?.sinaMessage?.text
                    ?? response?.sinaMessage?.data?.extra?.generalAnswer
                    ?? ""
                if aiText.isEmpty {
                    self.appendSinaMessage("عذرًا، لم أتمكن من قراءة رد سينا. حاول مرة أخرى.", time: self.formatTime(nil))
                } else {
                    self.appendSinaMessageWithTypewriter(aiText, time: self.formatTime(nil), aiMessage: response?.sinaMessage)
                }
            }
        }
    }

    private func appendSinaMessage(_ text: String, time: String, aiMessage: SinaMessage? = nil) {
        entries.append(SinaChatEntry(sender: .ai, text: text, time: time, aiMessage: aiMessage))
        tableView.reloadData(); scrollToBottom()
    }

    private func appendSinaMessageWithTypewriter(_ fullText: String, time: String, aiMessage: SinaMessage?) {
        let index = entries.count
        entries.append(SinaChatEntry(sender: .ai, text: "", time: time, aiMessage: aiMessage))
        tableView.reloadData(); scrollToBottom()

        let tokens = fullText.split(omittingEmptySubsequences: false) { $0 == " " }.map { String($0) }
        var idx = 0
        var built = ""
        typewriterTimer?.invalidate()
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] timer in
            guard let self = self, idx < tokens.count else { timer.invalidate(); return }
            built += (idx == 0 ? "" : " ") + tokens[idx]
            idx += 1
            if index < self.entries.count {
                self.entries[index].text = built
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                self.scrollToBottom()
            }
            if idx >= tokens.count { timer.invalidate() }
        }
    }

    private func setTyping(_ typing: Bool) {
        isTyping = typing
        typingRow.isHidden = !typing
        if typing { typingSpinner.startAnimating() } else { typingSpinner.stopAnimating() }
        refreshSendEnabled()
    }

    private func setAttaching(_ attaching: Bool) {
        isAttaching = attaching
        refreshSendEnabled()
    }

    private func formatTime(_ iso: String?) -> String {
        let df = DateFormatter(); df.dateFormat = "HH:mm"
        guard let iso = iso else { return df.string(from: Date()) }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        parser.locale = Locale(identifier: "en_US_POSIX")
        let date = parser.date(from: iso) ?? Date()
        return df.string(from: date)
    }

    // MARK: - Attachments

    @objc private func presentAttachmentMenu() {
        guard !isTyping, !isAttaching else { return }
        view.endEditing(true)
        let sheet = UIAlertController(title: "اختر مصدر الصورة", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "الكاميرا", style: .default) { [weak self] _ in self?.openCamera() })
        sheet.addAction(UIAlertAction(title: "المعرض",   style: .default) { [weak self] _ in self?.openGallery() })
        sheet.addAction(UIAlertAction(title: "مستند",    style: .default) { [weak self] _ in self?.openDocuments() })
        sheet.addAction(UIAlertAction(title: "إلغاء",    style: .cancel))
        if let pop = sheet.popoverPresentationController { pop.sourceView = attachBtn; pop.sourceRect = attachBtn.bounds }
        present(sheet, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "غير متاح", message: "الكاميرا غير متاحة على هذا الجهاز."); return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera; picker.delegate = self; picker.mediaTypes = ["public.image"]
        present(picker, animated: true)
    }

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary; picker.delegate = self; picker.mediaTypes = ["public.image"]
        present(picker, animated: true)
    }

    private func openDocuments() {
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf], asCopy: true)
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.image", "com.adobe.pdf"], in: .import)
        }
        picker.delegate = self; picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    private func handleAttachment(data: Data, type: String, name: String, isDocument: Bool) {
        guard let sessionId = sessionId else { return }
        setAttaching(true)

        let displayText = isDocument ? "📄 \(name)" : ""
        entries.append(SinaChatEntry(sender: .user, text: displayText, time: formatTime(nil), aiMessage: nil))
        tableView.reloadData(); scrollToBottom(); updateSuggestionsVisibility(); emptyLabel.isHidden = true

        ApiService.uploadSinaMedia(data: data, type: type) { [weak self] media, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if error != nil || media?.id == nil {
                    self.setAttaching(false)
                    if !self.entries.isEmpty { self.entries.removeLast(); self.tableView.reloadData() }
                    self.showAlert(title: "خطأ", message: "فشل رفع الملف.")
                    return
                }
                self.setAttaching(false)
                self.setTyping(true)
                ApiService.sendSinaMessage(sessionId: sessionId, text: "", mediaId: media!.id!) { [weak self] response, _, error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setTyping(false)
                        if error != nil {
                            self.appendSinaMessage("عذرًا، لم أتمكن من المعالجة. حاول مرة أخرى.", time: self.formatTime(nil)); return
                        }
                        let aiText = response?.sinaMessage?.text
                            ?? response?.sinaMessage?.data?.extra?.generalAnswer
                            ?? ""
                        if aiText.isEmpty {
                            self.appendSinaMessage("عذرًا، لم أتمكن من المعالجة. حاول مرة أخرى.", time: self.formatTime(nil))
                        } else {
                            self.appendSinaMessageWithTypewriter(aiText, time: self.formatTime(nil), aiMessage: response?.sinaMessage)
                        }
                    }
                }
            }
        }
    }

    private func scrollToBottom() {
        guard entries.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: entries.count - 1, section: 0), at: .bottom, animated: true)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyLabel.isHidden = !entries.isEmpty
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        switch entry.sender {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SinaUserCell", for: indexPath) as! SinaUserCell
            cell.configure(text: entry.text, time: entry.time)
            return cell
        case .ai:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SinaAICell", for: indexPath) as! SinaAICell
            cell.configure(text: entry.text, time: entry.time, message: entry.aiMessage)
            return cell
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { sendMessage(); return true }
}

// MARK: - AskSinaVC Picker Delegates

extension AskSinaVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.85) else {
            showAlert(title: "خطأ", message: "تعذر قراءة الصورة."); return
        }
        handleAttachment(data: data, type: "jpg", name: "photo-\(Int(Date().timeIntervalSince1970)).jpg", isDocument: false)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let needsRelease = url.startAccessingSecurityScopedResource()
        defer { if needsRelease { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            let ext = url.pathExtension.lowercased().isEmpty ? "bin" : url.pathExtension.lowercased()
            guard ["jpg", "jpeg", "png", "pdf"].contains(ext) else {
                showAlert(title: "غير مدعوم", message: "الأنواع المسموحة: JPG, PNG, PDF."); return
            }
            let isDoc = ext == "pdf"
            handleAttachment(data: data, type: ext, name: url.lastPathComponent, isDocument: isDoc)
        } catch {
            showAlert(title: "خطأ", message: "تعذر قراءة الملف.")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
}
