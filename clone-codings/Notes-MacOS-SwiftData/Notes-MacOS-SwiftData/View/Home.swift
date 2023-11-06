//
//  Home.swift
//  Notes-MacOS-SwiftData
//
//  Created by Eojin Choi on 2023/11/05.
//

import SwiftUI
import SwiftData

struct Home: View {
    /// List selection (카테고리로 필터링된 탭으로 활용하기 위함)
    @State private var selectedTag: String? = "All Notes"
    
    /// Quering all categories
    @Query(animation: .snappy) private var categories: [NoteCategory]
    
    /// Model context
    @Environment(\.modelContext) private var context
    
    /// View properties
    @State private var addCategory: Bool = false
    @State private var categoryTitle: String = ""
    @State private var requestedCategory: NoteCategory?
    @State private var deleteRequest: Bool = false
    @State private var renameRequest: Bool = false
    
    /// Dark mode toggle
    @State private var isDark: Bool = true
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTag) {
                Text("All Notes")
                    .tag("All Notes")
                    .foregroundColor(selectedTag == "All Notes" ? Color.primary : .gray)
                
                Text("Favorites")
                    .tag("Favorites")
                    .foregroundColor(selectedTag == "Favorites" ? Color.primary : .gray)
                
                /// User created categories
                Section {
                    ForEach(categories) { category in
                        Text(category.categoryTitle)
                            .tag(category.categoryTitle)
                            .foregroundStyle(selectedTag == category.categoryTitle ? Color.primary : .gray)
                            /// Some basic editing options
                            .contextMenu {
                                Button("Rename") {
                                    categoryTitle = category.categoryTitle
                                    requestedCategory = category
                                    renameRequest = true
                                }
                                
                                Button("Delete") {
                                    categoryTitle = category.categoryTitle
                                    requestedCategory = category
                                    deleteRequest = true
                                }
                            }
                    }
                } header: {
                    HStack(spacing: 5) {
                        Text("Categories")
                        
                        Button("", systemImage: "plus") {
                            addCategory.toggle()
                        }
                        .tint(.gray)
                        .buttonStyle(.plain)
                    }
                }
            }
        } detail: {
            /// Note view with dynamic filtering based on categories
            NotesView(category: selectedTag, allCategories: categories)
        }
        .navigationTitle(selectedTag ?? "All Notes")
        /// Adding category alert
        .alert("Add Category", isPresented: $addCategory) {
            TextField("Work", text: $categoryTitle)
            
            Button("Cancel", role: .cancel) {
                categoryTitle = ""
            }

            Button("Add") {
                /// Adding new category to SwiftData
                let category = NoteCategory(categoryTitle: categoryTitle)
                context.insert(category)
                categoryTitle = ""
            }
        }
        /// Rename alert
        .alert("Rename Category", isPresented: $renameRequest) {
            TextField("Work", text: $categoryTitle)
            
            Button("Cancel", role: .cancel) {
                categoryTitle = ""
                requestedCategory = nil
            }

            Button("Rename") {
                if let requestedCategory {
                    requestedCategory.categoryTitle = categoryTitle
                    categoryTitle = ""
                    self.requestedCategory = nil
                }
            }
        }
        /// Delete alert
        .alert("Are you sure to delete \(categoryTitle) category?", isPresented: $deleteRequest) {
            Button("Cancel", role: .cancel) {
                categoryTitle = ""
                requestedCategory = nil
            }

            Button("Delete", role: .destructive) {
                if let requestedCategory {
                    context.delete(requestedCategory)
                    categoryTitle = ""
                    self.requestedCategory = nil
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 10) {
                    Button("", systemImage: "plus") {
                        /// Adding new note
                        let note = Note(content: "")
                        context.insert(note)
                    }
                    
                    Button("", systemImage: isDark ? "sun.min" : "moon") {
                        /// Dark - Light mode changing
                        isDark.toggle()
                    }
                    .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .preferredColorScheme(isDark ? .dark : .light)
    }
}
