//
//  TaskList.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 13.02.2023.
//

import Foundation

// Модель списка задач
final class TaskList {
    var name = ""
    var date = Date()
    var tasks: [Task] = []
}

// Модель задачи
final class Task {
    var name = ""
    var note = ""
    var date = Date()
    var isComplete = false
}
