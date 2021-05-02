import UIKit

final class DiaryTableViewCell: UITableViewCell {
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var message: String? {
        get {
            messageLabel.text
        }
        set {
            messageLabel.text = newValue
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiaryTableViewCell: ViewCode {
    func buildViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
    }

    func buildConstraints() {
        titleLabel.makeConstraints(
            top: contentView.topAnchor,
            left: contentView.leadingAnchor,
            right: contentView.trailingAnchor,
            insets: .init(top: 8, left: 8, bottom: 0, right: 8)
        )

        messageLabel.makeConstraints(
            top: titleLabel.bottomAnchor,
            left: contentView.leadingAnchor,
            right: contentView.trailingAnchor,
            bottom: contentView.bottomAnchor,
            insets: .init(top: 8, left: 8, bottom: 8, right: 8)
        )
    }
}
