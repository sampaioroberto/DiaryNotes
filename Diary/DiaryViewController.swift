import UIKit

protocol SavingNotes: AnyObject {
    func save(note: DiaryNote)
}

enum DiarySection: Hashable {
    case main
}

enum NotesOption: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
}

final class DiaryViewController: UIViewController {

    private var notes = [
        DiaryNote(title: "Day 1", message: "Today I did many things"),
        DiaryNote(title: "Day 2", message: "Today I didn't do much", isFavorite: true),
        DiaryNote(title: "Day 3", message: "Today I rested", isFavorite: true)
    ]

    private var leftTableViewAnchor: NSLayoutConstraint?
    private var rightTableViewAnchor: NSLayoutConstraint?

    private var selectedZoomedView: UIView?
    private var selectedCellSnapshotFrame: CGRect?

    private lazy var optionsSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: NotesOption.allCases.map(\.rawValue))
        segmentedControl.addTarget(self, action: #selector(changedSegmentedControl), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

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
        view.addSubview(optionsSegmentedControl)
        view.addSubview(tableView)
    }

    func buildConstraints() {
        optionsSegmentedControl.makeConstraints(
            top: view.layoutMarginsGuide.topAnchor,
            left: view.leadingAnchor,
            right: view.trailingAnchor,
            insets: .zero
        )
        tableView.makeConstraints(
            top: optionsSegmentedControl.bottomAnchor,
            bottom: view.bottomAnchor,
            insets: .init(top: 8, left: 0, bottom: 0, right: 0)
        )
        leftTableViewAnchor = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        rightTableViewAnchor = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        leftTableViewAnchor?.isActive = true
        rightTableViewAnchor?.isActive = true
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

    @objc
    func changedSegmentedControl() {
        guard let optionString = optionsSegmentedControl.titleForSegment(at: optionsSegmentedControl.selectedSegmentIndex),
              let option = NotesOption(rawValue: optionString) else {
            return
        }
        configureInitialDiffableSnapshot(with: option)
        switchNotesOption(to: option)
    }

    func configureInitialDiffableSnapshot(with options: NotesOption = .all) {
        var snapshot = NSDiffableDataSourceSnapshot<DiarySection, UUID>()
        snapshot.appendSections([.main])
        switch options {
        case .all:
            snapshot.appendItems(notes.map(\.id))
        case .favorites:
            snapshot.appendItems(notes.filter{ $0.isFavorite }.map(\.id))
        }
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }

    func switchNotesOption(to option: NotesOption) {
        guard let tableViewSnapshot = tableView.snapshotView(afterScreenUpdates: true) else {
            return
        }

        view.addSubview(tableViewSnapshot)
        let leftSnapshotConstraint = tableViewSnapshot.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightSnapshotConstraint = tableViewSnapshot.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        leftSnapshotConstraint.isActive = true
        rightSnapshotConstraint.isActive = true
        tableViewSnapshot.makeConstraints(
            top: tableView.topAnchor,
            bottom: tableView.bottomAnchor,
            insets: .zero
        )
        leftTableViewAnchor?.constant = option == .all ? -self.tableView.frame.maxX : self.tableView.frame.maxX
        rightTableViewAnchor?.constant = option == .all ? -self.tableView.frame.maxX : self.tableView.frame.maxX
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
            self.leftTableViewAnchor?.constant = 0
            self.rightTableViewAnchor?.constant = 0
            leftSnapshotConstraint.constant = option == .all ? self.view.frame.maxX : -self.view.frame.maxX
            rightSnapshotConstraint.constant = option == .all ? self.view.frame.maxX : -self.view.frame.maxX
            self.view.layoutIfNeeded()
        }, completion: { _ in
            tableViewSnapshot.removeFromSuperview()
        })
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
        viewController.transitioningDelegate = self
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedZoomedView = selectedCell.snapshotView(afterScreenUpdates: true)
            selectedCellSnapshotFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        }

        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

extension DiaryViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = selectedCellSnapshotFrame,
              let view = selectedZoomedView else {
            return nil
        }
        let zoomAnimator = ZoomAnimator(frame: frame, view: view, isZoomingIn: true)
        return zoomAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = selectedCellSnapshotFrame,
            let view = selectedZoomedView else {
            return nil
        }
        let zoomAnimator = ZoomAnimator(frame: frame, view: view, isZoomingIn: false)
        return zoomAnimator
    }
}
