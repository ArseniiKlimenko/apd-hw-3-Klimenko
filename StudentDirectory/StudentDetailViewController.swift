import UIKit

// T3 red: neutral placeholder; the layout and fields follow in feat(T3).
final class StudentDetailViewController: UIViewController {
    let studentID: UUID
    private let store: StudentStore
    private let locale: Locale

    let avatarView = UIImageView()
    let nameLabel = UILabel()
    let idLabel = UILabel()
    let ageLabel = UILabel()
    let gradeLabel = UILabel()
    let scholarshipLabel = UILabel()
    let avatarNameLabel = UILabel()
    let subjectsTitleLabel = UILabel()
    private(set) var subjectButtons: [UIButton] = []
    let notFoundLabel = UILabel()

    init(store: StudentStore, studentID: UUID, locale: Locale = .current) {
        self.store = store
        self.studentID = studentID
        self.locale = locale
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }
}
