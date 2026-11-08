import UIKit

// T2 red: neutral placeholder; layout and configuration follow in feat(T2).
final class StudentCell: UITableViewCell {
    static let reuseIdentifier = "StudentCell"

    let avatarView = UIImageView()
    let nameLabel = UILabel()
    let ageLabel = UILabel()
    let gradeLabel = UILabel()
    let scholarshipLabel = UILabel()
    let contentStack = UIStackView()

    func configure(with student: Student, locale: Locale = .current) {}
}
