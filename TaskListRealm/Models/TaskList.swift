//
//  TaskList.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 13.02.2023.
//

import Foundation
import RealmSwift

// Модель списка задач
final class TaskList: Object {
	@Persisted var name = ""
	@Persisted var date = Date()
	@Persisted var tasks = List<Task>()
}

// Модель задачи
final class Task: Object {
	@Persisted var name = ""
	@Persisted var note = ""
	@Persisted var date = Date()
	@Persisted var isComplete = false
}
