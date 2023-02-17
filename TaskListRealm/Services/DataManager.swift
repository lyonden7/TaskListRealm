//
//  DataManager.swift
//  TaskListRealm
//
//  Created by Денис Васильев on 13.02.2023.
//

import Foundation

/// DataManager (Singleton) для создания начальных (временных) данных
final class DataManager {
	static let shared = DataManager()
	
	private init() {}
	
	// MARK: - Public Methods
	/// Метод для создания начальных (временных) данных
	func createTempData(completion: @escaping () -> Void) {
		if !UserDefaults.standard.bool(forKey: "done") {
			let shoppingList = TaskList()
			shoppingList.name = "Shopping list"
			
			let milk = Task()
			milk.name = "Milk"
			milk.note = "2L"
			
			let bread = Task(value: ["Bread", "", Date(), true])
			let apples = Task(value: ["name": "Apples", "note": "2Kg"])
			
			shoppingList.tasks.append(milk)
			shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
			
			let moviesList = TaskList()
			moviesList.name = "Movies List"
			
			let firstFilm = Task(value: ["Best film"])
			let secondFilm = Task(value: ["The best of the best film", "Must have", Date(), true])
			
			moviesList.tasks.insert(contentsOf: [firstFilm, secondFilm], at: 0)
			
			DispatchQueue.main.async {
				StorageManager.shared.save([shoppingList, moviesList])
				UserDefaults.standard.set(true, forKey: "done")
				completion()
			}
		}
	}
}
