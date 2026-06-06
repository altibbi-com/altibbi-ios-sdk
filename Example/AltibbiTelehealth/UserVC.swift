import UIKit
import AltibbiTelehealth

class UserVC: UIViewController {

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Management"
        view.backgroundColor = AppColors.background
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

        stack.addArrangedSubview(buildCard(
            title: "User Management",
            buttons: [
                ("Create User",                AppButtonVariant.primary,   #selector(goCreateUser)),
                ("Update User",                .secondary,                 #selector(goUpdateUser)),
                ("Get / Delete / List Users",  .secondary,                 #selector(goUserTools)),
            ]
        ))
    }

    private func buildCard(title: String, buttons: [(String, AppButtonVariant, Selector)]) -> UIView {
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

        let divider = UIView()
        divider.backgroundColor = AppColors.lightGray
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(divider)

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

    @objc private func goCreateUser() {
        navigationController?.pushViewController(CreateUserVC(), animated: true)
    }

    @objc private func goUpdateUser() {
        navigationController?.pushViewController(UpdateUserVC(), animated: true)
    }

    @objc private func goUserTools() {
        navigationController?.pushViewController(UserToolsVC(), animated: true)
    }
}
