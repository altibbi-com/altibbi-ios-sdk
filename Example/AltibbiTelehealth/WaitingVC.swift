import UIKit
import Foundation
import AltibbiTelehealth
import Lottie

class WaitingVC: UIViewController {

    var consultationInfo: Consultation?

    // Status pill
    private let statusPill = UIView()
    private let statusDot = UIView()
    private let statusLabel = UILabel()

    // Avatar w/ pulse
    private let avatarContainer = UIView()
    private let pulseOuter = UIView()
    private let pulseInner = UIView()
    private let avatarCard = UIView()
    private var doctorLottie: LottieAnimationView!
    private let doctorAvatarImg = UIImageView()
    private var pulseLayers: [CAShapeLayer] = []

    private let titleLbl = UILabel()
    private let subtitleLbl = UILabel()

    // Elapsed
    private let elapsedTitleLbl = UILabel()
    private let elapsedLbl = UILabel()
    private var elapsedTimer: Timer?
    private var startedAt = Date()

    // Tip card
    private let tipCard = UIView()
    private let tipLabel = UILabel()
    private var tipTimer: Timer?
    private var tipIndex = 0
    private let tips: [String] = [
        "تأكد من اتصالك بالإنترنت لضمان جودة المكالمة.",
        "جهّز قائمة بأعراضك ومدتها قبل بدء الاستشارة.",
        "اذكر الأدوية التي تتناولها حالياً للطبيب.",
        "احتفظ بنتائج التحاليل والأشعة قريبة منك.",
        "استخدم سماعات للحصول على صوت أوضح."
    ]

    // Cancel
    private let cancelBtn = UIButton(type: .system)
    private let cancelSpinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.semanticContentAttribute = .forceRightToLeft
        title = "غرفة الانتظار"
        view.backgroundColor = UIColor(hex: "#F8FBFF")
        applyGradientBackground()
        setupUI()
        startElapsedTimer()
        startTipsRotation()
        startConsultation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startedAt = Date()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { self.startPulseAnimation() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        elapsedTimer?.invalidate(); elapsedTimer = nil
        tipTimer?.invalidate(); tipTimer = nil
        stopPulseAnimation()
        doctorLottie?.stop()
    }

    private func applyGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "#EAF1FF").cgColor, UIColor(hex: "#F8FBFF").cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        view.layer.setValue(gradient, forKey: "bgGradient")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let g = view.layer.value(forKey: "bgGradient") as? CAGradientLayer {
            g.frame = view.bounds
        }
    }

    private func setupUI() {
        // Status pill
        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.backgroundColor = UIColor(red: 0x1B/255.0, green: 0x7E/255.0, blue: 0x3A/255.0, alpha: 0.12)
        statusPill.layer.cornerRadius = 16
        view.addSubview(statusPill)

        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.backgroundColor = UIColor(hex: "#1B7E3A")
        statusDot.layer.cornerRadius = 4
        statusPill.addSubview(statusDot)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "جاري الاتصال…"
        statusLabel.font = .systemFont(ofSize: 13, weight: .bold)
        statusLabel.textColor = UIColor(hex: "#1B7E3A")
        statusPill.addSubview(statusLabel)

        // Avatar container
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarContainer)

        pulseOuter.translatesAutoresizingMaskIntoConstraints = false
        pulseOuter.backgroundColor = AppColors.primary.withAlphaComponent(0.08)
        pulseOuter.layer.cornerRadius = 110
        avatarContainer.addSubview(pulseOuter)

        pulseInner.translatesAutoresizingMaskIntoConstraints = false
        pulseInner.backgroundColor = AppColors.primary.withAlphaComponent(0.12)
        pulseInner.layer.cornerRadius = 80
        avatarContainer.addSubview(pulseInner)

        avatarCard.translatesAutoresizingMaskIntoConstraints = false
        avatarCard.backgroundColor = .white
        avatarCard.layer.cornerRadius = 60
        avatarCard.layer.shadowColor = UIColor.black.cgColor
        avatarCard.layer.shadowOpacity = 0.15
        avatarCard.layer.shadowRadius = 8
        avatarCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        avatarContainer.addSubview(avatarCard)

        let doctorAnim = LottieAnimation.named("doctor", bundle: .main, subdirectory: "Lottie")
        doctorLottie = LottieAnimationView(animation: doctorAnim)
        doctorLottie.translatesAutoresizingMaskIntoConstraints = false
        doctorLottie.loopMode = .loop
        doctorLottie.contentMode = .scaleAspectFit
        doctorLottie.play()
        avatarCard.addSubview(doctorLottie)

        doctorAvatarImg.translatesAutoresizingMaskIntoConstraints = false
        doctorAvatarImg.contentMode = .scaleAspectFill
        doctorAvatarImg.clipsToBounds = true
        doctorAvatarImg.layer.cornerRadius = 60
        doctorAvatarImg.isHidden = true
        avatarCard.addSubview(doctorAvatarImg)

        // Title
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "نقوم بتجهيز جلستك"
        titleLbl.font = .systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = AppColors.text
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0
        view.addSubview(titleLbl)

        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false
        subtitleLbl.text = "بانتظار الطبيب لقبول الاستشارة"
        subtitleLbl.font = .systemFont(ofSize: 14)
        subtitleLbl.textColor = AppColors.gray
        subtitleLbl.textAlignment = .center
        subtitleLbl.numberOfLines = 0
        view.addSubview(subtitleLbl)

        // Elapsed
        elapsedTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        elapsedTitleLbl.text = "الوقت المنقضي"
        elapsedTitleLbl.font = .systemFont(ofSize: 12)
        elapsedTitleLbl.textColor = AppColors.gray
        elapsedTitleLbl.textAlignment = .center
        view.addSubview(elapsedTitleLbl)

        elapsedLbl.translatesAutoresizingMaskIntoConstraints = false
        elapsedLbl.text = "00:00"
        elapsedLbl.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        elapsedLbl.textColor = AppColors.primary
        elapsedLbl.textAlignment = .center
        view.addSubview(elapsedLbl)

        // Tip card
        tipCard.translatesAutoresizingMaskIntoConstraints = false
        tipCard.backgroundColor = .white
        tipCard.layer.cornerRadius = 20
        tipCard.layer.shadowColor = UIColor.black.cgColor
        tipCard.layer.shadowOpacity = 0.08
        tipCard.layer.shadowRadius = 6
        tipCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.addSubview(tipCard)

        let tipHeaderRow = UIStackView()
        tipHeaderRow.translatesAutoresizingMaskIntoConstraints = false
        tipHeaderRow.axis = .horizontal
        tipHeaderRow.spacing = 6
        tipHeaderRow.alignment = .center
        tipCard.addSubview(tipHeaderRow)

        let bulbLbl = UILabel(); bulbLbl.text = "💡"; bulbLbl.font = .systemFont(ofSize: 16)
        tipHeaderRow.addArrangedSubview(bulbLbl)

        let tipHeaderTitle = UILabel()
        tipHeaderTitle.text = "نصيحة"
        tipHeaderTitle.font = .systemFont(ofSize: 13, weight: .bold)
        tipHeaderTitle.textColor = AppColors.primary
        tipHeaderRow.addArrangedSubview(tipHeaderTitle)

        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.text = tips[0]
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textColor = AppColors.text
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .natural
        tipCard.addSubview(tipLabel)

        // Cancel
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.setTitle("إلغاء الاستشارة", for: .normal)
        cancelBtn.setTitleColor(AppColors.error, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelBtn.backgroundColor = .white
        cancelBtn.layer.cornerRadius = 14
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = AppColors.error.cgColor
        cancelBtn.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        view.addSubview(cancelBtn)

        cancelSpinner.translatesAutoresizingMaskIntoConstraints = false
        cancelSpinner.color = AppColors.error
        cancelSpinner.hidesWhenStopped = true
        cancelBtn.addSubview(cancelSpinner)

        NSLayoutConstraint.activate([
            statusPill.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusPill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusPill.heightAnchor.constraint(equalToConstant: 32),
            statusDot.trailingAnchor.constraint(equalTo: statusPill.trailingAnchor, constant: -14),
            statusDot.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusDot.leadingAnchor, constant: -8),
            statusLabel.leadingAnchor.constraint(equalTo: statusPill.leadingAnchor, constant: 14),
            statusLabel.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor),

            avatarContainer.topAnchor.constraint(equalTo: statusPill.bottomAnchor, constant: 40),
            avatarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 220),
            avatarContainer.heightAnchor.constraint(equalToConstant: 220),

            pulseOuter.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            pulseOuter.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            pulseOuter.widthAnchor.constraint(equalToConstant: 220),
            pulseOuter.heightAnchor.constraint(equalToConstant: 220),

            pulseInner.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            pulseInner.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            pulseInner.widthAnchor.constraint(equalToConstant: 160),
            pulseInner.heightAnchor.constraint(equalToConstant: 160),

            avatarCard.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarCard.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarCard.widthAnchor.constraint(equalToConstant: 120),
            avatarCard.heightAnchor.constraint(equalToConstant: 120),

            doctorLottie.topAnchor.constraint(equalTo: avatarCard.topAnchor, constant: 14),
            doctorLottie.leadingAnchor.constraint(equalTo: avatarCard.leadingAnchor, constant: 14),
            doctorLottie.trailingAnchor.constraint(equalTo: avatarCard.trailingAnchor, constant: -14),
            doctorLottie.bottomAnchor.constraint(equalTo: avatarCard.bottomAnchor, constant: -14),

            doctorAvatarImg.topAnchor.constraint(equalTo: avatarCard.topAnchor),
            doctorAvatarImg.leadingAnchor.constraint(equalTo: avatarCard.leadingAnchor),
            doctorAvatarImg.trailingAnchor.constraint(equalTo: avatarCard.trailingAnchor),
            doctorAvatarImg.bottomAnchor.constraint(equalTo: avatarCard.bottomAnchor),

            titleLbl.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 32),
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            subtitleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            elapsedTitleLbl.topAnchor.constraint(equalTo: subtitleLbl.bottomAnchor, constant: 20),
            elapsedTitleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            elapsedLbl.topAnchor.constraint(equalTo: elapsedTitleLbl.bottomAnchor, constant: 2),
            elapsedLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cancelBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelBtn.heightAnchor.constraint(equalToConstant: 52),

            cancelSpinner.centerXAnchor.constraint(equalTo: cancelBtn.centerXAnchor),
            cancelSpinner.centerYAnchor.constraint(equalTo: cancelBtn.centerYAnchor),

            tipCard.bottomAnchor.constraint(equalTo: cancelBtn.topAnchor, constant: -16),
            tipCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tipCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tipHeaderRow.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 18),
            tipHeaderRow.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor, constant: 18),

            tipLabel.topAnchor.constraint(equalTo: tipHeaderRow.bottomAnchor, constant: 8),
            tipLabel.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor, constant: 18),
            tipLabel.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor, constant: -18),
            tipLabel.bottomAnchor.constraint(equalTo: tipCard.bottomAnchor, constant: -18),
        ])

        // Load doctor avatar if present
        if let urlStr = consultationInfo?.doctorAvatar, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.doctorAvatarImg.image = img
                    self?.doctorAvatarImg.isHidden = false
                    self?.doctorLottie.isHidden = true
                }
            }.resume()
        }
    }

    // MARK: - Pulse animation

    private func startPulseAnimation() {
        stopPulseAnimation()
        let center = CGPoint(x: avatarContainer.bounds.midX, y: avatarContainer.bounds.midY)
        guard center.x > 0 else { return }
        for i in 0..<3 {
            let layer = CAShapeLayer()
            let radius: CGFloat = 60
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            layer.path = path.cgPath
            layer.fillColor = AppColors.primary.withAlphaComponent(0.18).cgColor
            layer.opacity = 0
            avatarContainer.layer.insertSublayer(layer, at: 0)
            pulseLayers.append(layer)

            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 0.7
            scale.toValue = 1.8
            let opacity = CABasicAnimation(keyPath: "opacity")
            opacity.fromValue = 0.6
            opacity.toValue = 0.0
            let group = CAAnimationGroup()
            group.animations = [scale, opacity]
            group.duration = 2.2
            group.repeatCount = .infinity
            group.beginTime = CACurrentMediaTime() + Double(i) * 0.7
            group.timingFunction = CAMediaTimingFunction(name: .easeOut)
            layer.add(group, forKey: "pulse")
        }
    }

    private func stopPulseAnimation() {
        pulseLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        pulseLayers.removeAll()
    }

    // MARK: - Timers

    private func startElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let secs = Int(Date().timeIntervalSince(self.startedAt))
            self.elapsedLbl.text = String(format: "%02d:%02d", secs / 60, secs % 60)
        }
    }

    private func startTipsRotation() {
        tipTimer?.invalidate()
        tipTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.tips.isEmpty else { return }
            self.tipIndex = (self.tipIndex + 1) % self.tips.count
            UIView.transition(with: self.tipLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.tipLabel.text = self.tips[self.tipIndex]
            })
        }
    }

    // MARK: - Status updates

    private func setStatus(pillText: String, title: String, subtitle: String) {
        DispatchQueue.main.async {
            UIView.transition(with: self.statusLabel, duration: 0.25, options: .transitionCrossDissolve) {
                self.statusLabel.text = pillText
            }
            UIView.transition(with: self.titleLbl, duration: 0.25, options: .transitionCrossDissolve) {
                self.titleLbl.text = title
            }
            UIView.transition(with: self.subtitleLbl, duration: 0.25, options: .transitionCrossDissolve) {
                self.subtitleLbl.text = subtitle
            }
        }
    }

    // MARK: - Flow

    private func startConsultation() {
        guard let info = consultationInfo else { return }
        if info.status == "in_progress" {
            setStatus(pillText: "بدء الاستشارة", title: "الاستشارة جارية", subtitle: "نقوم بفتح شاشة الاستشارة الآن")
            openConsultationScreen()
        } else if let appKey = info.socketKey, let channelName = info.socketChannel {
            TBISocket.initiateSocket(appKey: appKey, channelName: channelName, onEvent: onEvent)
        }
    }

    func onEvent(name: String, data: String?) {
        guard let data = data else { return }
        print("onEvent >>> \(name) : \(data)")
        if name == "pusher:subscription_error" {
            setStatus(pillText: "خطأ في الاتصال", title: "خطأ في الاتصال", subtitle: "تعذر الاتصال بالخادم. حاول مرة أخرى.")
        } else if name == "pusher:subscription_succeeded" {
            setStatus(pillText: "تم الاتصال", title: "بانتظار الطبيب", subtitle: "سيتم إعلامك فور قبول الطبيب.")
        } else if data == "accepted" {
            setStatus(pillText: "تم القبول", title: "قبل الطبيب الاستشارة", subtitle: "الطبيب يراجع معلوماتك الآن")
        } else if data == "in_progress" {
            setStatus(pillText: "بدء الاستشارة", title: "الاستشارة جارية", subtitle: "نقوم بفتح الشاشة الآن")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.openConsultationScreen()
            }
        }
    }

    func openConsultationScreen() {
        guard let consId = consultationInfo?.consultationId else { return }
        ApiService.getConsultationInfo(id: consId) { consultation, failure, error in
            if let error = error {
                print("openConsultationScreen error: \(error)")
            } else if let failure = failure {
                ResponseFailure.printJsonData(failure)
            } else if let consultation = consultation {
                DispatchQueue.main.async {
                    self.navigateToConsultation(consultation)
                }
            }
        }
    }

    private func navigateToConsultation(_ consultation: Consultation) {
        if consultation.chatConfig != nil {
            let vc = ChatConsultationVC()
            vc.consultationInfo = consultation
            navigationController?.pushViewController(vc, animated: true)
        } else if consultation.videoConfig != nil || consultation.voipConfig != nil {
            let vc = VideoConsultationVC()
            vc.consultationInfo = consultation
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func cancelClicked() {
        guard let info = consultationInfo, let consId = info.consultationId else { return }
        showConfirm(title: "إلغاء الاستشارة", message: "هل أنت متأكد من إلغاء هذه الاستشارة؟", destructive: "إلغاء") {
            self.setCancelLoading(true)
            ApiService.cancelConsultation(id: Int(consId)) { _, failure, error in
                DispatchQueue.main.async { self.setCancelLoading(false) }
                if let error = error {
                    print("cancelClicked error: \(error)")
                } else if let failure = failure {
                    ResponseFailure.printJsonData(failure)
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "تم الإلغاء", message: "تم إلغاء الاستشارة بنجاح") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    private func setCancelLoading(_ loading: Bool) {
        if loading {
            cancelBtn.setTitle("", for: .normal)
            cancelSpinner.startAnimating()
            cancelBtn.isEnabled = false
        } else {
            cancelBtn.setTitle("إلغاء الاستشارة", for: .normal)
            cancelSpinner.stopAnimating()
            cancelBtn.isEnabled = true
        }
    }
}
