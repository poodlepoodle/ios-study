# `Notes-MacOS-SwiftData`

- [SwiftUI: Building Notes App + SwiftData + CRUD | macOS 14 | Xcode 15](https://www.youtube.com/watch?v=Pmd6L0BaeXs)
- SwiftData를 이용해 Mac OS에서 간단한 Notes 앱의 CRUD를 구현했습니다.

<br />

## 핵심 구현 내용

### 1. 뷰 그리기

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/90198a6b-39b0-43a2-a5b1-1c29cf88f440" />

```swift
var body: some View {
        NavigationSplitView {
            List(selection: $selectedTag) {
                // ...
            }
        } detail: {
            NotesView(category: selectedTag, allCategories: categories)
        }
        .navigationTitle(selectedTag ?? "All Notes")
        // alerts...
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // ...
            }
        }
        .preferredColorScheme(isDark ? .dark : .light)
    }
```

- `NavigationSplitView`를 이용해 좌측의 카테고리를 구성했고, 위쪽의 `.toolbar`로 메모 추가와 라이트-다크 모드 전환을 할 수 있도록 구성했습니다.

### 2. SwiftData CRUD

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/c68b7b77-c10f-454c-99fd-e9ec76590f97" />

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/14373918-d5ac-473c-8e22-c23c3e4b27ea" />

```swift
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
```

```swift
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
```

- SwiftData에서 제공하는 `@Model` 프로퍼티 래퍼를 이용해 `Note`와 `NoteCategory` 클래스를 정의하고, 둘 사이의 종속 관계를 `@Relationship`으로 적용했습니다.

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/d6d397cb-6b8f-4bc2-b70b-7dee9460c1e0" />

```swift
struct NotesView: View {
    var category: String?
    var allCategories: [NoteCategory]
    
    @Query private var notes: [Note]
    
    init(category: String?, allCategories: [NoteCategory]) {
        self.category = category
        self.allCategories = allCategories
        
        /// Dynamic filtering
        let predicate = #Predicate<Note> {
            return $0.category?.categoryTitle == category
        }
        let favoritePredicate = #Predicate<Note> {
            return $0.isFavorite
        }
        let finalPredicate = category == "All Notes" ? nil : (category == "Favorites" ? favoritePredicate : predicate)
        
        _notes = Query(filter: finalPredicate, sort: [], animation: .snappy)
    }

    /// ...
```

- 즐겨찾기(Favorite)와 각 카테고리에 속한 노트들만을 보여주어야 하는 경우에는, 마찬가지로 SwiftData에서 제공하는 `@Query`와 Predicate을 이용한 Dynamic Filtering을 활용했습니다.

```swift
// 모델 컨텍스트 연결
@Environment(\.modelContext) private var context

// 노트 및 카테고리에 추가
context.insert(note)
context.insert(category)

// 노트 및 카테고리에 제거
context.delete(note)
context.delete(requestedCategory)

// 노트의 속성 설정
note.category = category    // 추가
note.category = nil         // 제거
note.isFavorite.toggle()
```

- SwiftData에서 제공하는 `modelContext` 환경 변수를 통해 `insert()`, `delete()` 메서드에 접근할 수 있었고, 아주 간단히 노트와 카테고리의 추가 및 제거를 구현할 수 있었습니다.

### 3. 라이트 - 다크 모드

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/b2521409-c97a-49d1-879b-86ef818f5bf6" />

<img width="1045" alt="image" src="https://github.com/poodlepoodle/ios-study/assets/6462456/3ec27f85-cda5-4082-ae3b-
fb53ef44b019" />

```swift
        NavigationSplitView { ... }
        // ...
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 10) {
                    // ...
                    
                    Button("", systemImage: isDark ? "sun.min" : "moon") {
                        isDark.toggle()
                    }
                    .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .preferredColorScheme(isDark ? .dark : .light)
```

- toolbar에 위치한 라이트 - 다크 모드 전환 버튼을 클릭했을 때, `isDark` 값을 토글하도록 했고 이에 따라 `NavigationSplitView` 전체에 적용된 `.preferredColorScheme`가 적용되도록 했습니다.
