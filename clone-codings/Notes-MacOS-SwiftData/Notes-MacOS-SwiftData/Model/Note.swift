//
//  Note.swift
//  Notes-MacOS-SwiftData
//
//  Created by Eojin Choi on 2023/11/04.
//

import SwiftUI
import SwiftData

@Model
class Note {
    var content: String
    var isFavorite: Bool = false
    var category: NoteCategory?
    
    init(content: String, category: NoteCategory? = nil) {
        self.content = content
        self.category = category
    }
}
