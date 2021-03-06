import Foundation

struct DiaryNote: Equatable {
    let id = UUID()
    var title: String
    var message: String
    var isFavorite = false

    static func == (lhs: DiaryNote, rhs: DiaryNote) -> Bool {
        return lhs.id == rhs.id
    }
}
