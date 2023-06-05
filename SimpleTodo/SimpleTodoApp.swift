//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  Created by Isini Bandara on 2023-06-05.
//

import SwiftUI

@main
struct SimpleTodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
