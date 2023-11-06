//
//  NoteCategory.swift
//  Notes-MacOS-SwiftData
//
//  Created by Eojin Choi on 2023/11/04.
//

import SwiftUI
import SwiftData

@Model
class NoteCategory {
    var categoryTitle: String
    /// Relationship
    @Relationship(deleteRule: .cascade, inverse: \Note.category)
    var notes: [Note]?
    
    init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
    }
}
