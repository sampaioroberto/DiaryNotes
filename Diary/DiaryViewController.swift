import UIKit

protocol SavingNotes: AnyObject {
    func save(note: DiaryNote)
}

enum DiarySection: Hashable {
    case main
}

final class DiaryViewController: UIViewController {

    private var notes = [
        DiaryNote(title: "Dia 1", message: "Today I did many things"),
        DiaryNote(title: "Dia 2", message: "Today I didn't do much"),
        DiaryNote(title: "Dia 3", message: "Today I rested")
    ]

    private let tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 46.0
        return view
    }()

    private lazy var tableViewDataSource: EditEnabledDiffableDataSource = {
        let dataSource = EditEnabledDiffableDataSource(tableView: tableView) { [weak self] tableView, _, id in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryTableViewCell.self)) as? DiaryTableViewCell else {
                return UITableViewCell()
            }

            if let note = self?.notes.first(where: { $0.id == id }) {
                cell.title = note.title
                cell.message = note.message
            }

            return cell
        }
        dataSource.deleteClosure = { id in
            self.notes.removeAll(where: { $0.id == id})
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        tableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: String(describing: DiaryTableViewCell.self))
        tableView.delegate = self
        configureInitialDiffableSnapshot()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

extension DiaryViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(tableView)
    }

    func buildConstraints() {
        tableView.makeConstraintsEqualsToSuperview()
    }

    func configureView() {
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addDiaryNote)
        )
    }
}

private extension DiaryViewController {
    @objc
    func addDiaryNote() {
        let viewController = AddEditViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    func configureInitialDiffableSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<DiarySection, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes.map(\.id))
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension DiaryViewController: SavingNotes {
    func save(note: DiaryNote) {
        var snapshot = tableViewDataSource.snapshot()
        if let index = notes.firstIndex(of: note) {
            notes[index] = note
            snapshot.reloadItems([note.id])
        } else {
            notes.append(note)
            snapshot.appendItems([note.id])
        }
        tableViewDataSource.apply(snapshot)
    }
}

extension DiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        let viewController = AddEditViewController(note: note)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}
