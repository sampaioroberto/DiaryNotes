import Foundation

struct DiaryNote: Hashable {
    let id = UUID()
    var title: String
    var message: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DiaryNote, rhs: DiaryNote) -> Bool {
        return lhs.id == rhs.id
    }
}
