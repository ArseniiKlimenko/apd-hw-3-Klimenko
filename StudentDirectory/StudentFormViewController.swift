import UIKit

/// T6.2 red stub: the form exists so the tests compile; nothing is wired yet.
final class StudentFormViewController: UIViewController {
    let nameField = UITextField()
    let ageField = UITextField()
    let errorLabel = UILabel()
    var onSave: (() -> Void)?

    private let store: StudentStore

    init(store: StudentStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func save() {}

    func cancel() {}
}
