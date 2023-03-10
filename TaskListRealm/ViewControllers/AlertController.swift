//
//  AlertController.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 13.02.2023.
//

import UIKit

extension UIAlertController {
	
	/// Метод для создания UIAlertController
	static func createAlert(withTitle title: String, andMessage message: String) -> UIAlertController {
		UIAlertController(title: title, message: message, preferredStyle: .alert)
	}
	
	/// Метод для создания UIAlertAction для UIAlertController для экрана со списками задач
	func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
		let doneButton = taskList == nil ? "Save" : "Update"
		
		let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
			guard let newValue = self.textFields?.first?.text else { return }
			guard !newValue.isEmpty else { return }
			completion(newValue)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		
		addAction(saveAction)
		addAction(cancelAction)
		
		addTextField { textField in
			textField.placeholder = "List Name"
			textField.text = taskList?.name
		}
	}
	
	/// Метод для создания UIAlertAction для UIAlertController для экрана с задачами
	func action(with task: Task?, completion: @escaping (String, String) -> Void) {
		let title = task == nil ? "Save" : "Update"
		
		let saveAction = UIAlertAction(title: title, style: .default) { _ in
			guard let newTask = self.textFields?.first?.text else { return }
			guard !newTask.isEmpty else { return }
			
			if let note = self.textFields?.last?.text, !note.isEmpty {
				completion(newTask, note)
			} else {
				completion(newTask, "")
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		
		addAction(saveAction)
		addAction(cancelAction)
		
		addTextField { textField in
			textField.placeholder = "New task"
			textField.text = task?.name
		}
		
		addTextField { textField in
			textField.placeholder = "Note"
			textField.text = task?.note
		}
	}
}
