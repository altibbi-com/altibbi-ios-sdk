import UIKit
import AltibbiTelehealth

class HomeVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Altibbi Example"
        view.backgroundColor = AppColors.background
        navigationItem.hidesBackButton = true
        setupScrollView()
        setupContent()
    }

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
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AppLayout.spacing
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.padding),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.padding),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.padding),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.padding),
        ])

        // Card 1: Digital Health Services
        let card1 = buildCard(
            title: "Digital Health Services",
            subtitle: "Access expert consultation and AI assistance",
            buttons: [
                ("New Consultation", AppButtonVariant.primary, #selector(goConsultation)),
                ("Ask Sina (AI Chat)", .secondary, #selector(goAskSina)),
                ("My Consultations", .secondary, #selector(goConsultationList)),
            ]
        )
        stack.addArrangedSubview(card1)

        // Card 2: Administration
        let card2 = buildCard(
            title: "Administration",
            subtitle: "Manage configurations and users",
            buttons: [
                ("User Management", AppButtonVariant.secondary, #selector(goUser)),
            ]
        )
        stack.addArrangedSubview(card2)
    }

    private func buildCard(title: String, subtitle: String, buttons: [(String, AppButtonVariant, Selector)]) -> UIView {
        let card = AppCardView()
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AppLayout.spacing
        card.addSubview(stack)

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 18, weight: .bold)
        titleLbl.textColor = AppColors.text
        stack.addArrangedSubview(titleLbl)

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = .systemFont(ofSize: 14)
        subtitleLbl.textColor = AppColors.gray
        stack.addArrangedSubview(subtitleLbl)

        for (label, variant, sel) in buttons {
            let btn = AppButton(title: label, variant: variant)
            btn.addTarget(self, action: sel, for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppLayout.cardPadding),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppLayout.cardPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppLayout.cardPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppLayout.cardPadding),
        ])
        return card
    }

    // MARK: - Navigation

    @objc private func goConsultation() {
        navigationController?.pushViewController(ConsultationVC(), animated: true)
    }

    @objc private func goFollowUp() {
        navigationController?.pushViewController(FollowUpVC(), animated: true)
    }

    @objc private func goAskSina() {
        navigationController?.pushViewController(SinaHomeVC(), animated: true)
    }

    @objc private func goConsultationList() {
        navigationController?.pushViewController(ConsultationListVC(), animated: true)
    }

    @objc private func goUser() {
        navigationController?.pushViewController(UserVC(), animated: true)
    }
}
