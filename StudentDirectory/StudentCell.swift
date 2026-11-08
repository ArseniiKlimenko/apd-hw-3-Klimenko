import SnapKit
import UIKit

/// Reusable list row: avatar, name, age, average grade and scholarship status.
final class StudentCell: UITableViewCell {
    static let reuseIdentifier = "StudentCell"

    let avatarView = UIImageView()
    let nameLabel = UILabel()
    let ageLabel = UILabel()
    let gradeLabel = UILabel()
    let scholarshipLabel = UILabel()
    /// Avatar and texts: side by side normally, stacked for accessibility text sizes (R-23).
    let contentStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
        updateLayout(for: traitCollection.preferredContentSizeCategory)
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: StudentCell, _: UITraitCollection) in
            cell.updateLayout(for: cell.traitCollection.preferredContentSizeCategory)
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with student: Student, locale: Locale = .current) {
        avatarView.image = UIImage(named: student.avatarName) ?? UIImage(named: "avatar-default")
        nameLabel.text = student.name
        ageLabel.text = StudentFormatting.age(student.age)
        gradeLabel.text = StudentFormatting.grade(student.averageGrade, locale: locale)
        scholarshipLabel.text = StudentFormatting.scholarship(student.isScholarshipHolder)
        accessibilityIdentifier = "studentCell.\(student.id.uuidString)"
        accessibilityLabel = StudentFormatting.accessibilityLabel(for: student, locale: locale)
    }

    private func setUpViews() {
        isAccessibilityElement = true

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        for label in [ageLabel, gradeLabel, scholarshipLabel] {
            label.font = .preferredFont(forTextStyle: .subheadline)
        }
        for label in [nameLabel, ageLabel, gradeLabel, scholarshipLabel] {
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }

        avatarView.contentMode = .scaleAspectFit
        let textStack = UIStackView(arrangedSubviews: [nameLabel, ageLabel, gradeLabel, scholarshipLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        contentStack.addArrangedSubview(avatarView)
        contentStack.addArrangedSubview(textStack)
        contentStack.spacing = 12
        contentView.addSubview(contentStack)

        avatarView.snp.makeConstraints { make in
            make.size.equalTo(56)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
    }

    private func updateLayout(for category: UIContentSizeCategory) {
        let isAccessibilitySize = category.isAccessibilityCategory
        contentStack.axis = isAccessibilitySize ? .vertical : .horizontal
        contentStack.alignment = isAccessibilitySize ? .leading : .center
    }
}
