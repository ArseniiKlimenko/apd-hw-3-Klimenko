import SnapKit
import UIKit

/// Two-field form for a new student (R-43). The store is the only validation
/// authority (R-48); the form only turns the age text into a number (R-47).
final class StudentFormViewController: UIViewController {
    static let blankNameMessage = "Name must not be blank"
    static let invalidAgeMessage = "Age must be a positive whole number"

    let nameField = UITextField()
    let ageField = UITextField()
    let errorLabel = UILabel()
    /// Called once after a successful save, before the form closes (R-46).
    var onSave: (() -> Void)?

    private let store: StudentStore
    private let stack = UIStackView()

    init(store: StudentStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Student"
        view.backgroundColor = .systemBackground

        let save = UIBarButtonItem(systemItem: .save, primaryAction: UIAction { [weak self] _ in self?.save() })
        save.accessibilityIdentifier = "saveStudentButton"
        navigationItem.rightBarButtonItem = save
        let cancel = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in self?.cancel() })
        cancel.accessibilityIdentifier = "cancelStudentButton"
        navigationItem.leftBarButtonItem = cancel

        configure(nameField, placeholder: "Name", identifier: "studentNameField")
        nameField.textContentType = .name
        nameField.autocorrectionType = .no
        configure(ageField, placeholder: "Age", identifier: "studentAgeField")
        ageField.keyboardType = .numberPad

        errorLabel.accessibilityIdentifier = "studentFormError"
        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true

        stack.axis = .vertical
        stack.spacing = 12
        for row in [nameField, ageField, errorLabel] {
            stack.addArrangedSubview(row)
        }
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    func save() {
        // R-47, R-54: the age must be a whole number exactly as typed.
        guard let age = Int(ageField.text ?? "") else {
            showError(Self.invalidAgeMessage)
            return
        }
        do {
            try store.addStudent(name: nameField.text ?? "", age: age)
        } catch {
            showError(message(for: error))
            return
        }
        onSave?()
        dismiss(animated: true)
    }

    func cancel() {
        dismiss(animated: true)
    }

    private func message(for error: Error) -> String {
        switch error as? StudentStoreError {
        case .blankName: Self.blankNameMessage
        case .nonPositiveAge: Self.invalidAgeMessage
        case .unknownID: "Student not found"
        case nil: error.localizedDescription
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func configure(_ field: UITextField, placeholder: String, identifier: String) {
        field.placeholder = placeholder
        field.accessibilityLabel = placeholder
        field.accessibilityIdentifier = identifier
        field.borderStyle = .roundedRect
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
    }
}
