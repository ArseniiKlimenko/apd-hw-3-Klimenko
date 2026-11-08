import SnapKit
import UIKit

/// Lists the students of the shared store.
final class StudentListViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .plain)
    private let store: StudentStore

    /// R-7: read from the store on every call, never cached.
    private var students: [Student] {
        store.students
    }

    init(store: StudentStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Students"
        view.backgroundColor = .systemBackground

        tableView.accessibilityIdentifier = "studentList"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.register(StudentCell.self, forCellReuseIdentifier: StudentCell.reuseIdentifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension StudentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        students.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentCell.reuseIdentifier, for: indexPath)
        (cell as? StudentCell)?.configure(with: students[indexPath.row])
        return cell
    }
}

extension StudentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let details = StudentDetailViewController(store: store, studentID: students[indexPath.row].id)
        navigationController?.pushViewController(details, animated: true)
    }
}
