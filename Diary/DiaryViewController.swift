import UIKit

protocol SavingNotes: AnyObject {
    func save(note: DiaryNote)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: String(describing: DiaryTableViewCell.self))
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
}

extension DiaryViewController: SavingNotes {
    func save(note: DiaryNote) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            notes.append(note)
            tableView.insertRows(at: [IndexPath(row: notes.count-1, section: 0)], with: .automatic)
        }
    }
}

extension DiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DiaryTableViewCell.self)) as? DiaryTableViewCell else {
            return UITableViewCell()
        }
        let note = notes[indexPath.row]
        cell.title = note.title
        cell.message = note.message
        return cell
    }
}

extension DiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let diaryNote = notes.remove(at: sourceIndexPath.row)
        notes.insert(diaryNote, at: destinationIndexPath.row)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let viewController = AddEditViewController(note: note)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}
