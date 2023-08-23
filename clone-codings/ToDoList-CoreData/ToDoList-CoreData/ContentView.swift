//
//  ContentView.swift
//  ToDoList-CoreData
//
//  Created by Eojin Choi on 2023/08/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
