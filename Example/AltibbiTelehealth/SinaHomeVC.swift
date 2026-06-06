import UIKit
import AltibbiTelehealth
import Lottie

class SinaHomeVC: UIViewController {

    private static let bgColor = UIColor(hex: "#F8F9FE")

    private let headerCard = UIView()
    private let backBtn = UIButton(type: .system)
    private let titleLbl = UILabel()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let heroAvatarBg = UIView()
    private let heroAvatarImg = UIImageView()
    private let heroTitle = UILabel()
    private let heroSubtitle = UILabel()

    private let footerView = UIView()
    private let footerFiller = UIView()
    private let feedbackLbl = UILabel()
    private let startBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.semanticContentAttribute = .forceRightToLeft
        view.backgroundColor = SinaHomeVC.bgColor
        setupHeader()
        setupFooter()
        setupScroll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Header

    private func setupHeader() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.backgroundColor = SinaHomeVC.bgColor
        view.addSubview(headerCard)

        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = AppColors.text
        backBtn.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        headerCard.addSubview(backBtn)

        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "اسأل سينا"
        titleLbl.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLbl.textColor = AppColors.text
        headerCard.addSubview(titleLbl)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerCard.heightAnchor.constraint(equalToConstant: 48),

            backBtn.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 12),
            backBtn.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),

            titleLbl.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 8),
            titleLbl.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
        ])
    }

    @objc private func backPressed() { navigationController?.popViewController(animated: true) }

    // MARK: - Scroll content

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeHeroSection())
        contentStack.addArrangedSubview(makeFeatureGrid())

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerCard.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    private func makeHeroSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        heroAvatarBg.translatesAutoresizingMaskIntoConstraints = false
        heroAvatarBg.backgroundColor = .white
        heroAvatarBg.layer.cornerRadius = 50
        heroAvatarBg.applyShadow(opacity: 0.12, radius: 6, offset: CGSize(width: 0, height: 3))
        container.addSubview(heroAvatarBg)

        heroAvatarImg.translatesAutoresizingMaskIntoConstraints = false
        heroAvatarImg.image = UIImage(named: "master_logo")
        heroAvatarImg.contentMode = .scaleAspectFit
        heroAvatarBg.addSubview(heroAvatarImg)

        heroTitle.translatesAutoresizingMaskIntoConstraints = false
        heroTitle.text = "مرحبًا، أنا سينا"
        heroTitle.font = .systemFont(ofSize: 28, weight: .bold)
        heroTitle.textColor = AppColors.text
        heroTitle.textAlignment = .center
        container.addSubview(heroTitle)

        heroSubtitle.translatesAutoresizingMaskIntoConstraints = false
        heroSubtitle.text = "مساعدك الصحي الذكي المتقدم"
        heroSubtitle.font = .systemFont(ofSize: 16, weight: .bold)
        heroSubtitle.textColor = AppColors.gray
        heroSubtitle.textAlignment = .center
        heroSubtitle.numberOfLines = 0
        container.addSubview(heroSubtitle)

        NSLayoutConstraint.activate([
            heroAvatarBg.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            heroAvatarBg.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            heroAvatarBg.widthAnchor.constraint(equalToConstant: 100),
            heroAvatarBg.heightAnchor.constraint(equalToConstant: 100),

            heroAvatarImg.centerXAnchor.constraint(equalTo: heroAvatarBg.centerXAnchor),
            heroAvatarImg.centerYAnchor.constraint(equalTo: heroAvatarBg.centerYAnchor),
            heroAvatarImg.widthAnchor.constraint(equalToConstant: 60),
            heroAvatarImg.heightAnchor.constraint(equalToConstant: 60),

            heroTitle.topAnchor.constraint(equalTo: heroAvatarBg.bottomAnchor, constant: 20),
            heroTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            heroTitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            heroSubtitle.topAnchor.constraint(equalTo: heroTitle.bottomAnchor, constant: 8),
            heroSubtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            heroSubtitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            heroSubtitle.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -32),
        ])
        return container
    }

    private struct Feature {
        let lottie: String
        let tint: UIColor
        let title: String
        let desc: String
    }

    private func makeFeatureGrid() -> UIView {
        let features: [Feature] = [
            .init(lottie: "health_risk_assessment", tint: UIColor(hex: "#FFEAEA"), title: "فحص الأعراض", desc: "حلّل أعراضك على الفور"),
            .init(lottie: "medicine_tablet",        tint: UIColor(hex: "#E7F5EE"), title: "معلومات الأدوية", desc: "الاستخدام والآثار الجانبية والمزيد"),
            .init(lottie: "lock_animation",         tint: UIColor(hex: "#E8EEFE"), title: "خصوصية وأمان", desc: "بياناتك محمية دائمًا"),
            .init(lottie: "hours",                  tint: UIColor(hex: "#FFF4E0"), title: "متاح 24/7", desc: "دائمًا هنا عندما تحتاجني"),
        ]

        let outer = UIView()
        outer.translatesAutoresizingMaskIntoConstraints = false

        let row1 = makeRow(left: features[0], right: features[1])
        let row2 = makeRow(left: features[2], right: features[3])

        let vStack = UIStackView(arrangedSubviews: [row1, row2])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 12
        outer.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: outer.topAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: outer.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: outer.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: outer.bottomAnchor, constant: -20),
        ])
        return outer
    }

    private func makeRow(left: Feature, right: Feature) -> UIView {
        let row = UIStackView(arrangedSubviews: [makeFeatureCard(left), makeFeatureCard(right)])
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }

    private func makeFeatureCard(_ f: Feature) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.applyShadow(opacity: 0.06, radius: 6, offset: CGSize(width: 0, height: 2))

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = f.tint
        iconBg.layer.cornerRadius = 12
        card.addSubview(iconBg)

        let animation = LottieAnimation.named(f.lottie, bundle: .main, subdirectory: "Lottie")
        let animView = LottieAnimationView(animation: animation)
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.loopMode = .loop
        animView.contentMode = .scaleAspectFit
        animView.play()
        iconBg.addSubview(animView)

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = f.title
        titleLbl.font = .systemFont(ofSize: 15, weight: .bold)
        titleLbl.textColor = AppColors.text
        titleLbl.numberOfLines = 0
        card.addSubview(titleLbl)

        let descLbl = UILabel()
        descLbl.translatesAutoresizingMaskIntoConstraints = false
        descLbl.text = f.desc
        descLbl.font = .systemFont(ofSize: 12)
        descLbl.textColor = AppColors.gray
        descLbl.numberOfLines = 0
        card.addSubview(descLbl)

        NSLayoutConstraint.activate([
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            animView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            animView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            animView.widthAnchor.constraint(equalTo: iconBg.widthAnchor, multiplier: 0.8),
            animView.heightAnchor.constraint(equalTo: iconBg.heightAnchor, multiplier: 0.8),

            titleLbl.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 12),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            descLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            descLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            descLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
        return card
    }

    // MARK: - Footer

    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = SinaHomeVC.bgColor
        view.addSubview(footerView)

        footerFiller.translatesAutoresizingMaskIntoConstraints = false
        footerFiller.backgroundColor = SinaHomeVC.bgColor
        view.addSubview(footerFiller)

        feedbackLbl.translatesAutoresizingMaskIntoConstraints = false
        feedbackLbl.font = .systemFont(ofSize: 13, weight: .bold)
        feedbackLbl.textAlignment = .center
        feedbackLbl.numberOfLines = 0
        feedbackLbl.isHidden = true
        feedbackLbl.layer.cornerRadius = 8
        feedbackLbl.layer.masksToBounds = true
        footerView.addSubview(feedbackLbl)

        startBtn.translatesAutoresizingMaskIntoConstraints = false
        startBtn.setTitle("ابدأ جلسة جديدة", for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        startBtn.backgroundColor = AppColors.primary
        startBtn.layer.cornerRadius = 12
        startBtn.addTarget(self, action: #selector(startSession), for: .touchUpInside)
        footerView.addSubview(startBtn)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.hidesWhenStopped = true
        startBtn.addSubview(spinner)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            footerFiller.topAnchor.constraint(equalTo: footerView.bottomAnchor),
            footerFiller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerFiller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerFiller.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            feedbackLbl.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            feedbackLbl.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            feedbackLbl.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),

            startBtn.topAnchor.constraint(equalTo: feedbackLbl.bottomAnchor, constant: 12),
            startBtn.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            startBtn.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            startBtn.heightAnchor.constraint(equalToConstant: 52),
            startBtn.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -12),

            spinner.centerXAnchor.constraint(equalTo: startBtn.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: startBtn.centerYAnchor),
        ])
    }

    // MARK: - Start session

    @objc private func startSession() {
        guard !isLoading else { return }
        guard AltibbiService.sinaEndpoint != nil else {
            showFeedback("لم يتم تعيين رابط سينا. أدخل الرابط في شاشة تسجيل الدخول.", error: true)
            return
        }
        setLoading(true)
        feedbackLbl.isHidden = true

        ApiService.createSinaSession { [weak self] session, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoading(false)
                if let error = error {
                    self.showFeedback(error.localizedDescription, error: true); return
                }
                guard let sid = session?.id else {
                    self.showFeedback("تم بدء الجلسة لكن لم يتم استلام المعرف.", error: true); return
                }
                let chatVC = AskSinaVC()
                chatVC.initialSessionId = sid
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        isLoading = loading
        startBtn.isEnabled = !loading
        startBtn.alpha = loading ? 0.7 : 1.0
        if loading {
            startBtn.setTitle("", for: .normal)
            spinner.startAnimating()
        } else {
            startBtn.setTitle("ابدأ جلسة جديدة", for: .normal)
            spinner.stopAnimating()
        }
    }

    private func showFeedback(_ message: String, error: Bool) {
        feedbackLbl.isHidden = false
        feedbackLbl.text = "  \(message)  "
        if error {
            feedbackLbl.backgroundColor = UIColor(red: 0xE4/255.0, green: 0x3F/255.0, blue: 0x3F/255.0, alpha: 0.15)
            feedbackLbl.textColor = AppColors.error
        } else {
            feedbackLbl.backgroundColor = UIColor(red: 0x51/255.0, green: 0xCF/255.0, blue: 0x66/255.0, alpha: 0.15)
            feedbackLbl.textColor = AppColors.success
        }
    }
}
