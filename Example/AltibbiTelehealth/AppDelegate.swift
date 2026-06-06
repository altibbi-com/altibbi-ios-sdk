import UIKit
import AltibbiTelehealth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureNavBarAppearance()
        AltibbiService.enableDebugLog = true
        AltibbiService.initService(
            token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2luc3VyYW5jZS5hbHRpYmIuY29tLyIsImF1ZCI6Imh0dHBzOi8vaW5zdXJhbmNlLmFsdGliYi5jb20vIiwiaWF0IjoxNzc4NTA2MDUwLCJuYmYiOjE3Nzg1MDYwNTAsImV4cCI6MTc3ODUwOTY1MCwidWlkIjozNjkwLCJkYXRhIjoib3JrUXN5SkJqMlhCd09YT204Sk1BNjlzYWlBZkcxMFNZZ3lJMUJRM1UrcmZHYTRZVndsbXJyREpWdlUrSTRTRVE4ei8wcUtsSzJTWHZyaHhYSTZZNENFR3ppdURwZUFwQWEvSDgwWGU0dDVZQ2tSMHJnUVdhZUNTTTVKNHJhY0Y2WkFWanlOMWQ2cGpKaVFxY20zUWtrSnFsb1Bhc3VpM29wRm9IckhHek9peGpiSXFuSU9rNFhjbkptSzFPUmVqMjhlcHRjbWw4aDU0KzUyWWhqa0xWcmtJdmcraGJMVDF2ejE3RkhwUG5DU1BGd1pXYjJGTWVjMzVUMHRnU1JNOW9tTlRlMmR0RTdOR0s2Q1MxSmZZNUFXNjRzaE51YjFwMFFJM1EyLzRuME13alpQZnAzV0c0aUQxOHBwYUZQdkpma24wcjFHMjlXREhWeVNkVmJBY2F5WmFuanJLcjBYOEljVm5YNWxzNk9xU2JQOHhseVZZaTZmQmRIQUVyNHYyY1hLSGgyZDhNUk5IdmovbnZWbEJQeExvbkdzdkY1Z09VUTE5VVI3SFg0QlNOLzVPQm92cUV0ZmJ4UjdFZzhGOWVqZ0h6eUFyTEhRQXU1V254a2M0eENBcHRVdHBKMU9QSWRtMnBNOVdCcStUcGI3Z1phT0xBTnQ5NHNvN1V2QlpUYXdIUzF4T3lzMmpBcXRmZlJ6QlIySjRkdENVYTNGcjlDMXhCWHczWnY5NjVwUlV4MXJ4SlIxZkJITnEyZTJOWTRGeUR3bU1XR0RXOFBGb0FPZmxJcXRpZU9tSDdGVkJCRlhkeDR4MzUwMUhSQnZTKzVXQUx6K2xYeHBiaTVrWCJ9.DEmoHVe12ltuFefhc5yf6VJ7759kp89sHoADLGsN3myLc0xUhrNZBerZFLVYGVl1UiQ3vdIdlg0XO16mR8W1ClYafDnm_WAvRimr1_wEK70C89d9fI88M07wEFn-0ljDBBKaPXDL90xbKFvsz0lftVfw4VmhCsngsJY-Z3nV7vG7nrkJJcOnVqprFm5JjasH-pSlr4kQq0yP8k_04XCmI1tZOTjACwOA2zQbxLEob-lQc7ds_u0fAOoV24lH-Jcv9bUYcBora2Nyj23ig7bJqcwM5HYB3J7bDaDEAf6Wj-tr8_xTWJiULFXuW_b00oxtUiWcybmVylpMAG17GTEwgFXaCX4TH0-EDcd_KJqXlCU5Ce7tCttcyKe3eT8x72phdSUAiyF92VpwsPb2OM5Lpkvr_1n_WYVEi3o61_7NZMGD3hLBf9d8ec7fazRbJjp7RmuegD--6WvfOZ08AbO0SL3qOpFOZJf-8cqf50fg0Qm5rj5mogWrqeVCooxMlGEHxYtlf2UFVY1W-ITB13TRwWDJq3kBUj3h3NaxDl6FVQFy__7YJhZDeGUomFwFzq4IDvporDd1pDvvphZtRQPM5-gZlh8_I_4BjjCIwtNnZdVhr0xL3k_hwaVWDKAElsVQCMdQw_DOHJO7wEGA0K-ijK3IOiVEazXNKaX6Us9HBWQ",
            baseUrl: "insurance.altibb.com",
            language: "en",
            sinaModelEndPoint: "https://stg.asksina.ai/partners"
        )
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: HomeVC())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }

    private func configureNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.primary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
}

// MARK: - Theme

struct AppColors {
    static let primary    = UIColor(hex: "#0e0eea")
    static let secondary  = UIColor(hex: "#0920b1")
    static let background = UIColor(hex: "#F3F3F4")
    static let text       = UIColor(hex: "#333333")
    static let gray       = UIColor(hex: "#888888")
    static let lightGray  = UIColor(hex: "#E0E0E0")
    static let white      = UIColor.white
    static let error      = UIColor(hex: "#e43f3f")
    static let success    = UIColor(hex: "#51CF66")
}

struct AppLayout {
    static let cornerRadius:     CGFloat = 12
    static let cardCornerRadius: CGFloat = 16
    static let padding:          CGFloat = 20
    static let cardPadding:      CGFloat = 20
    static let buttonHeight:     CGFloat = 50
    static let inputHeight:      CGFloat = 50
    static let spacing:          CGFloat = 12
}

extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8)  / 255
        let b = CGFloat(rgb & 0x0000FF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIView {
    func applyShadow(opacity: Float = 0.05, radius: CGFloat = 10, offset: CGSize = CGSize(width: 0, height: 2)) {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius  = radius
        layer.shadowOffset  = offset
        layer.masksToBounds = false
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - AppCardView

class AppCardView: UIView {
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.white
        layer.cornerRadius = AppLayout.cardCornerRadius
        applyShadow(opacity: 0.05, radius: 10, offset: CGSize(width: 0, height: 2))
    }
}

// MARK: - AppHeaderView

class AppHeaderView: UIView {
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()

    convenience init(title: String, subtitle: String? = nil) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text      = title
        titleLabel.font      = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = AppColors.text
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        if let subtitle = subtitle {
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.text      = subtitle
            subtitleLabel.font      = .systemFont(ofSize: 16)
            subtitleLabel.textColor = AppColors.gray
            addSubview(subtitleLabel)
            NSLayoutConstraint.activate([
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        } else {
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    func updateSubtitle(_ text: String) { subtitleLabel.text = text }
}

// MARK: - AppButton

enum AppButtonVariant { case primary, secondary, danger }

class AppButton: UIButton {
    private var variant: AppButtonVariant = .primary
    private let spinner = UIActivityIndicatorView(style: .medium)

    convenience init(title: String, variant: AppButtonVariant = .primary) {
        self.init(type: .system)
        self.variant = variant
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        layer.cornerRadius = AppLayout.cornerRadius
        applyVariant()
        setupSpinner()
        heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight).isActive = true
    }

    override var isEnabled: Bool { didSet { alpha = isEnabled ? 1 : 0.5 } }

    private func applyVariant() {
        switch variant {
        case .primary:
            backgroundColor = AppColors.primary
            setTitleColor(.white, for: .normal)
        case .secondary:
            backgroundColor = .white
            setTitleColor(AppColors.primary, for: .normal)
            layer.borderWidth = 2
            layer.borderColor = AppColors.primary.cgColor
        case .danger:
            backgroundColor = AppColors.error
            setTitleColor(.white, for: .normal)
        }
    }

    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = variant == .secondary ? AppColors.primary : .white
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func setLoading(_ loading: Bool) {
        if loading {
            spinner.startAnimating(); titleLabel?.alpha = 0; isEnabled = false
        } else {
            spinner.stopAnimating(); titleLabel?.alpha = 1; isEnabled = true
        }
    }
}

// MARK: - AppTextFieldView

class AppTextFieldView: UIView {
    let textField  = UITextField()
    let errorLabel = UILabel()
    var onTextChange: ((String) -> Void)?
    var text: String? { get { textField.text } set { textField.text = newValue } }

    convenience init(label: String? = nil, placeholder: String = "", keyboardType: UIKeyboardType = .default, isSecure: Bool = false, isMultiline: Bool = false) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        var prevBottom: NSLayoutYAxisAnchor = topAnchor
        var prevOffset: CGFloat = 0

        if let label = label {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text      = label
            lbl.font      = .systemFont(ofSize: 14, weight: .semibold)
            lbl.textColor = AppColors.text
            addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: topAnchor),
                lbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                lbl.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            prevBottom = lbl.bottomAnchor
            prevOffset = 8
        }

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder       = placeholder
        textField.font              = .systemFont(ofSize: 16)
        textField.textColor         = AppColors.text
        textField.backgroundColor   = AppColors.white
        textField.layer.cornerRadius = AppLayout.cornerRadius
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.keyboardType      = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.leftView  = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode  = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.rightViewMode = .always
        textField.applyShadow(opacity: 0.05, radius: 4, offset: CGSize(width: 0, height: 1))
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: prevBottom, constant: prevOffset),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: AppLayout.inputHeight),
        ])

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font      = .systemFont(ofSize: 12)
        errorLabel.textColor = AppColors.error
        errorLabel.numberOfLines = 0
        errorLabel.isHidden  = true
        addSubview(errorLabel)

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func textChanged() {
        onTextChange?(textField.text ?? "")
        clearError()
    }

    func setError(_ msg: String?) {
        guard let msg = msg, !msg.isEmpty else { clearError(); return }
        errorLabel.text   = msg
        errorLabel.isHidden = false
        textField.layer.borderColor = AppColors.error.cgColor
    }

    func clearError() {
        errorLabel.isHidden = true
        textField.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: - AppTextViewField

class AppTextViewField: UIView, UITextViewDelegate {
    let textView = UITextView()
    private let placeholderLabel = UILabel()
    var onTextChange: ((String) -> Void)?
    var text: String? {
        get { textView.text }
        set { textView.text = newValue; placeholderLabel.isHidden = !(newValue?.isEmpty ?? true) }
    }

    convenience init(label: String? = nil, placeholder: String = "") {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        var prevBottom: NSLayoutYAxisAnchor = topAnchor
        var prevOffset: CGFloat = 0

        if let label = label {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = label; lbl.font = .systemFont(ofSize: 14, weight: .semibold); lbl.textColor = AppColors.text
            addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: topAnchor),
                lbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                lbl.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            prevBottom = lbl.bottomAnchor; prevOffset = 8
        }

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16); textView.textColor = AppColors.text
        textView.backgroundColor = AppColors.white; textView.layer.cornerRadius = AppLayout.cornerRadius
        textView.layer.borderWidth = 1; textView.layer.borderColor = UIColor.clear.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isScrollEnabled = false; textView.delegate = self
        textView.applyShadow(opacity: 0.05, radius: 4, offset: CGSize(width: 0, height: 1))
        addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: prevBottom, constant: prevOffset),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = placeholder
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .systemGray3
        placeholderLabel.numberOfLines = 0
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -16),
        ])
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        onTextChange?(textView.text)
    }
}

// MARK: - RadioGroupView

class RadioGroupView: UIView {
    private let titleLabel   = UILabel()
    private let scrollView   = UIScrollView()
    private let buttonsStack = UIStackView()
    private var options: [String] = []
    private var buttons: [UIButton] = []
    private(set) var selectedIndex: Int = 0
    var onSelectionChanged: ((String) -> Void)?
    var selectedValue: String { options[safe: selectedIndex] ?? "" }

    convenience init(title: String, options: [String], selectedIndex: Int = 0) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.options = options
        self.selectedIndex = selectedIndex

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title; titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = AppColors.text
        addSubview(titleLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)

        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal; buttonsStack.spacing = 8
        scrollView.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 38),

            buttonsStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            buttonsStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])

        for (i, opt) in options.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(opt.capitalized, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            btn.layer.cornerRadius = 8
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            btn.tag = i
            btn.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
            buttons.append(btn); buttonsStack.addArrangedSubview(btn)
        }
        updateStyles()
    }

    @objc private func btnTapped(_ sender: UIButton) {
        selectedIndex = sender.tag; updateStyles()
        onSelectionChanged?(options[safe: selectedIndex] ?? "")
    }

    private func updateStyles() {
        for (i, btn) in buttons.enumerated() {
            if i == selectedIndex {
                btn.backgroundColor = AppColors.primary; btn.setTitleColor(.white, for: .normal)
                btn.layer.borderWidth = 0
            } else {
                btn.backgroundColor = .white; btn.setTitleColor(AppColors.primary, for: .normal)
                btn.layer.borderWidth = 1.5; btn.layer.borderColor = AppColors.primary.cgColor
            }
        }
    }

    func setSelectedValue(_ value: String) {
        if let idx = options.firstIndex(of: value) { selectedIndex = idx; updateStyles() }
    }
}

// MARK: - FeedbackView

enum FeedbackType {
    case success, error, info
    var bg: UIColor {
        switch self {
        case .success: return AppColors.success.withAlphaComponent(0.15)
        case .error:   return AppColors.error.withAlphaComponent(0.15)
        case .info:    return AppColors.primary.withAlphaComponent(0.1)
        }
    }
    var fg: UIColor {
        switch self { case .success: return AppColors.success; case .error: return AppColors.error; case .info: return AppColors.primary }
    }
}

class FeedbackView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8; layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor; isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center; label.numberOfLines = 0
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    func show(message: String, type: FeedbackType) {
        label.text = message; label.textColor = type.fg
        backgroundColor = type.bg
        layer.borderColor = type.fg.withAlphaComponent(0.2).cgColor
        isHidden = false
    }

    func hide() { isHidden = true }
}

// MARK: - SectionTitleLabel helper

class SectionTitleLabel: UILabel {
    convenience init(_ text: String) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.text      = text
        self.font      = .systemFont(ofSize: 18, weight: .bold)
        self.textColor = AppColors.text
    }
}

// MARK: - Divider helper

class SectionDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.lightGray
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UIViewController helpers

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }

    func showConfirm(title: String, message: String, destructive: String = "Delete", action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: destructive, style: .destructive) { _ in action() })
        present(alert, animated: true)
    }
}
