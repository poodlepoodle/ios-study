//
//  ToDoList_CoreDataApp.swift
//  ToDoList-CoreData
//
//  Created by Eojin Choi on 2023/08/21.
//

import SwiftUI

@main
struct ToDoList_CoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
