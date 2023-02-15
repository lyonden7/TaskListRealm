//
//  StorageManager.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 13.02.2023.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - Task List
    /// Метод для работы с DataManager, для внутреннего использования. Этот метод будет вызываться в DataManager один раз для сохранения всех начальных данных.
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    /// Метод для сохранения списка задач, вызываемый по нажатию на кнопку "Save" в AlertController
    func save(_ taskList: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    /// Метод для удаления списка задач
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    /// Метод для редактирования списка задач
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    /// Метод, позволяющий отметить все задачи как выполненные
    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Tasks
    /// Метод для добавления задачи
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [task, note])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    // MARK: - Private Methods
    /// Метод для безопасной работы с БД
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
