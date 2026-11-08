import SnapKit
import UIKit

/// Shows every field of one student (R-8); keeps only the id and reads the
/// student from the shared store (R-7).
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

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    init(store: StudentStore, studentID: UUID, locale: Locale = .current) {
        self.store = store
        self.studentID = studentID
        self.locale = locale
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "studentDetails"
        setUpLayout()

        if let student = store.students.first(where: { $0.id == studentID }) {
            show(student)
        } else {
            showNotFound()
        }
    }

    private func setUpLayout() {
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.width.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
    }

    private func show(_ student: Student) {
        title = student.name

        avatarView.image = UIImage(named: student.avatarName) ?? UIImage(named: "avatar-default")
        avatarView.contentMode = .scaleAspectFit
        avatarView.isAccessibilityElement = true
        avatarView.accessibilityLabel = "Avatar of \(student.name)"
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(120)
        }

        configure(nameLabel, text: student.name, style: .title1)
        configure(idLabel, text: StudentFormatting.identifier(student.id), style: .footnote, secondary: true)
        configure(ageLabel, text: StudentFormatting.age(student.age), style: .body)
        configure(gradeLabel, text: StudentFormatting.grade(student.averageGrade, locale: locale), style: .body)
        configure(scholarshipLabel, text: StudentFormatting.scholarship(student.isScholarshipHolder), style: .body)
        configure(avatarNameLabel, text: StudentFormatting.avatarName(student.avatarName), style: .footnote, secondary: true)
        configure(subjectsTitleLabel, text: "Subjects", style: .headline)

        subjectButtons = student.subjects.map(makeSubjectButton)

        let rows: [UIView] = [avatarView, nameLabel, idLabel, ageLabel, gradeLabel, scholarshipLabel, avatarNameLabel, subjectsTitleLabel]
        for row in rows + subjectButtons {
            stack.addArrangedSubview(row)
        }
    }

    private func showNotFound() {
        configure(notFoundLabel, text: "Student not found", style: .body)
        stack.addArrangedSubview(notFoundLabel)
    }

    private func makeSubjectButton(_ subject: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(subject, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.accessibilityIdentifier = "subjectButton.\(subject)"
        if let titleLabel = button.titleLabel {
            configure(titleLabel, text: subject, style: .body)
        }
        // R-37: the action captures its subject, so no lookup by tag or title.
        button.addAction(UIAction { [weak self] _ in self?.showStudents(with: subject) }, for: .touchUpInside)
        return button
    }

    private func showStudents(with subject: String) {
        navigationController?.pushViewController(StudentListViewController(store: store, subject: subject), animated: true)
    }

    private func configure(_ label: UILabel, text: String, style: UIFont.TextStyle, secondary: Bool = false) {
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        if secondary {
            label.textColor = .secondaryLabel
        }
    }
}
