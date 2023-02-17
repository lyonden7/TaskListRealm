//
//  TasksViewController.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 06.02.2023.
//

import UIKit
import RealmSwift

final class TasksViewController: UITableViewController {
	
	// MARK: - Public Properties
	/// Список задач, получаемый из предыдущего контроллера TaskListViewController
	var taskList: TaskList!
	
	// MARK: - Private Properties
	/// Список текущих (невыполненных) задач, с типом для Realm
	private var currentTasks: Results<Task>!
	/// Список выполненных задач, с типом для Realm
	private var completedTasks: Results<Task>!
	
	// MARK: - Life Cycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		currentTasks = taskList.tasks.filter("isComplete = false")
		completedTasks = taskList.tasks.filter("isComplete = true")
	}
	
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		section == 0 ? currentTasks.count : completedTasks.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
		var content = cell.defaultContentConfiguration()
		let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
		content.text = task.name
		content.secondaryText = task.note
		cell.contentConfiguration = content
		return cell
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
			StorageManager.shared.delete(task)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
		
		let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
			showAlert(with: task) {
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			isDone(true)
		}
		
		let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
		let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [unowned self] _, _, isDone in
			let isComplete = indexPath.section == 0 ? true : false
			StorageManager.shared.done(task, isComplete: isComplete) {
				let currentTaskIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
				let completeTaskIndex = IndexPath(row: completedTasks.index(of: task) ?? 0, section: 1)
				let indexReplace = indexPath.section == 0 ? completeTaskIndex : currentTaskIndex
				tableView.moveRow(at: indexPath, to: indexReplace)
			}
			isDone(true)
		}
		
		editAction.backgroundColor = .orange
		doneAction.backgroundColor = .systemGreen
		
		return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
	}
	
	@objc
	private func addButtonPressed() {
		showAlert()
	}
}

// MARK: - Table View Delegate
extension TasksViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - Private Methods
extension TasksViewController {
	private func setupNavigationBar() {
		title = taskList.name
		
		let addButton = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonPressed)
		)
		
		navigationItem.rightBarButtonItems = [addButton, editButtonItem]
	}
	
	private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
		let title = task != nil ? "Edit task" : "New task"
		
		let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
		
		alert.action(with: task) { [weak self] taskName, taskNote in
			if let task = task, let completion = completion {
				StorageManager.shared.edit(task, newName: taskName, newNote: taskNote)
				completion()
			} else {
				self?.save(task: taskName, withNote: taskNote)
			}
		}
		
		present(alert, animated: true)
	}
	
	private func save(task: String, withNote note: String) {
		StorageManager.shared.save(task, withNote: note, to: taskList) { task in
			let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
			tableView.insertRows(at: [rowIndex], with: .automatic)
		}
	}
}
