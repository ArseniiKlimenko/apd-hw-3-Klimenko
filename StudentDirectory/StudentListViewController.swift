import SnapKit
import UIKit

/// Lists the students of the shared store.
final class StudentListViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .plain)
    private let store: StudentStore
    /// R-6: with a subject this is the filtered list.
    let subject: String?

    /// R-7: read from the store on every call, never cached.
    private var students: [Student] {
        guard let subject else { return store.students }
        return store.students(matchingSubject: subject)
    }

    init(store: StudentStore, subject: String? = nil) {
        self.store = store
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = subject ?? "Students"
        // R-44: only the main list can add (a new student has no subjects).
        if subject == nil {
            let add = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in self?.showAddForm() })
            add.accessibilityIdentifier = "addStudentButton"
            add.accessibilityLabel = "Add student"
            navigationItem.rightBarButtonItem = add
        }
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

    /// Presents the add form (R-43); after a save the list reloads and shows
    /// the new last row (R-46, R-52).
    func showAddForm() {
        let form = StudentFormViewController(store: store)
        form.onSave = { [weak self] in self?.showAddedStudent() }
        present(UINavigationController(rootViewController: form), animated: true)
    }

    private func showAddedStudent() {
        tableView.reloadData()
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        guard lastRow >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
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
