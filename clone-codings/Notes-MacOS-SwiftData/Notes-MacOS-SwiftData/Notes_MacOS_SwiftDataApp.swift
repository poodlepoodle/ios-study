//
//  Notes_MacOS_SwiftDataApp.swift
//  Notes-MacOS-SwiftData
//
//  Created by Eojin Choi on 2023/11/04.
//

import SwiftUI

@main
struct Notes_MacOS_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                /// Setting min frame
                .frame(minWidth: 320, minHeight: 400)
        }
        // Adding Data Model to the App
        .modelContainer(for: [Note.self, NoteCategory.self])
    }
}
