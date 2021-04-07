import UIKit

final class AddEditViewController: UIViewController {
    weak var delegate: SavingNotes?

    private var note: DiaryNote?

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8.0
        stackView.axis = .vertical
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        return label
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 4.0
        return textField
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Message"
        return label
    }()

    private let messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 4.0
        return textView
    }()

    init(note: DiaryNote? = nil) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
}

extension AddEditViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(titleTextField)
        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(messageTextView)
    }

    func buildConstraints() {
        contentStackView.makeConstraints(
            top: view.layoutMarginsGuide.topAnchor,
            left: view.leadingAnchor,
            right: view.trailingAnchor,
            insets: .init(top: 8, left: 8, bottom: 0, right: 8)
        )
        titleTextField.makeConstraints(height: 30)
        messageTextView.makeConstraints(height: 100)
    }

    func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNote))
        titleTextField.text = note?.title
        messageTextView.text = note?.message
    }
}

private extension AddEditViewController {
    @objc
    func saveNote() {
        guard let title = titleTextField.text,
              let message = messageTextView.text,
              !title.isEmpty,
              !message.isEmpty else {
            return
        }

        if var note = note {
            note.title = title
            note.message = message
            delegate?.save(note: note)
        } else {
            let savingNote = DiaryNote(title: title, message: message)
            delegate?.save(note: savingNote)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
