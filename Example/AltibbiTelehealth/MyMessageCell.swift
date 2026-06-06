import UIKit
import SendbirdChatSDK

class MyMessageCell: UITableViewCell {

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let messageImageView = UIImageView()
    private let timeLabel = UILabel()

    private var imageHeightConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = AppColors.primary
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        bubbleView.addSubview(messageLabel)

        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.clipsToBounds = true
        messageImageView.layer.cornerRadius = 14
        messageImageView.isHidden = true
        bubbleView.addSubview(messageImageView)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = AppColors.gray
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)

        imageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: 150)
        imageWidthConstraint = messageImageView.widthAnchor.constraint(equalToConstant: 200)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),

            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 4),
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 4),
            messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -4),
            messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4),

            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -4),
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with message: BaseMessage) {
        let text = message.message
        if isImageUrl(text) {
            messageLabel.isHidden = true
            messageImageView.isHidden = false
            imageHeightConstraint.isActive = true
            imageWidthConstraint.isActive = true
            loadImage(text)
        } else {
            messageLabel.isHidden = false
            messageImageView.isHidden = true
            imageHeightConstraint.isActive = false
            imageWidthConstraint.isActive = false

            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            messageLabel.attributedText = NSAttributedString(
                string: text,
                attributes: [.paragraphStyle: style,
                             .font: UIFont.systemFont(ofSize: 16),
                             .foregroundColor: UIColor.white]
            )
        }

        let date = Date(timeIntervalSince1970: Double(message.createdAt) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: date)
    }

    private func isImageUrl(_ url: String) -> Bool {
        let path = url.trimmingCharacters(in: .whitespaces).split(separator: "?").first.map(String.init) ?? ""
        let lower = path.lowercased()
        return lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") || lower.hasSuffix(".png")
            || lower.hasSuffix(".gif") || lower.hasSuffix(".heic") || lower.hasSuffix(".webp")
    }

    private func loadImage(_ urlStr: String) {
        guard let url = URL(string: urlStr.trimmingCharacters(in: .whitespaces)) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.messageImageView.image = img }
        }.resume()
    }
}
