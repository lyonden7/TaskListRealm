//
//  TaskListViewCell.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 17.02.2023.
//

import UIKit

class TaskListViewCell: UITableViewCell {
	/// Метод для конфигурации ячейки списка задач, выставляет необходимое значение secondaryText в зависимости от количества невыполненных задач в списке.
	func configure(_ taskList: TaskList) {
		let currentTasks = taskList.tasks.filter("isComplete = false")
		var content = defaultContentConfiguration()
		
		content.text = taskList.name
		
		if taskList.tasks.isEmpty {
			content.secondaryText = "0"
			accessoryType = .none
		} else if currentTasks.isEmpty {
			accessoryType = .checkmark
		} else {
			content.secondaryText = "\(currentTasks.count)"
			accessoryType = .none
		}
		
		contentConfiguration = content
	}
}
