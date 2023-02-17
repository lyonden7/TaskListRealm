//
//  TaskListsViewController.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 06.02.2023.
//

import UIKit
import RealmSwift

/// Контроллер, в котором отображаются списки задач
final class TaskListsViewController: UITableViewController {
	
	// MARK: - Public Properties
	/// Списки задач
	var taskLists: Results<TaskList>!
	
	// MARK: - Life Cycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		createTempData()
		taskLists = StorageManager.shared.realm.objects(TaskList.self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	// MARK: - Table view data source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		taskLists.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as! TaskListViewCell
		cell.configure(taskLists[indexPath.row])
		return cell
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let taskList = taskLists[indexPath.row]
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
			StorageManager.shared.delete(taskList)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
		
		let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
			showAlert(with: taskList) {
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			isDone(true)
		}
		
		let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
			StorageManager.shared.done(taskList)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			isDone(true)
		}
		
		editAction.backgroundColor = .orange
		doneAction.backgroundColor = .systemGreen
		
		return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		guard let taskVC = segue.destination as? TasksViewController else { return }
		let taskList = taskLists[indexPath.row]
		taskVC.taskList = taskList
	}
	
	@IBAction func sortingList(_ sender: UISegmentedControl) {
		taskLists = sender.selectedSegmentIndex == 0
		? taskLists.sorted(byKeyPath: "date")
		: taskLists.sorted(byKeyPath: "name")
		
		tableView.reloadData()
	}
	
	@objc
	private func addButtonPressed() {
		showAlert()
	}
}

// MARK: - Table View Delegate
extension TaskListsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - Private Methods
extension TaskListsViewController {
	private func setupNavigationBar() {
		let addButton = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonPressed)
		)
		
		navigationItem.rightBarButtonItem = addButton
		navigationItem.leftBarButtonItem = editButtonItem
	}
	
	private func createTempData() {
		DataManager.shared.createTempData { [unowned self] in
			tableView.reloadData()
		}
	}
	
	private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
		let title = taskList != nil ? "Edit List" : "New List"
		let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
		
		alert.action(with: taskList) { [weak self] newValue in
			if let taskList = taskList, let completion = completion {
				StorageManager.shared.edit(taskList, newValue: newValue)
				completion()
			} else {
				self?.save(taskList: newValue)
			}
		}
		
		present(alert, animated: true)
	}
	
	private func save(taskList: String) {
		StorageManager.shared.save(taskList) { taskList in
			let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
			tableView.insertRows(at: [rowIndex], with: .automatic)
		}
	}
}
