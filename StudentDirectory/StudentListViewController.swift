import UIKit

// T2 red: neutral placeholder; the table, title and data source follow in feat(T2).
final class StudentListViewController: UIViewController {
    let tableView = UITableView()
    private let store: StudentStore

    init(store: StudentStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }
}
