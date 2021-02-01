import Foundation

/// Protocol for adding and removing the favorites and for fetching the favorites.
protocol Favoritable {
    func addToFavorites(item: Item)
    func removeFromFavorites(item: Item)
    func favorites() -> [Item]
    func toggleFavorite(for item: Item)
}

/// Class for managing the persistence.
class PersistenceManager: Favoritable {
    private let FavoritesKey = "favoritesKey"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func addToFavorites(item: Item) {
        var favorites: [Data] = []

        if let favs = userDefaults.value(forKey: FavoritesKey) as? [Data] {
            favorites = favs
        }

        guard let encodedItem = self.encodedItem(item) else { return }

        favorites.append(encodedItem)
        userDefaults.set(favorites, forKey: FavoritesKey)
    }

    func removeFromFavorites(item: Item) {
        guard var favs = userDefaults.value(forKey: FavoritesKey) as? [Data], let encodedItem = self.encodedItem(item), let index = favs.firstIndex(of: encodedItem) else { return }

        favs.remove(at: index)
        userDefaults.set(favs, forKey: FavoritesKey)
    }

    func favorites() -> [Item] {
        guard let savedItems = userDefaults.value(forKey: FavoritesKey) as? [Data] else { return [] }
        return savedItems.compactMap { self.decodeItem(from: $0) }
    }

    func toggleFavorite(for item: Item) {
        if let favs = userDefaults.value(forKey: FavoritesKey) as? [Data], let encodedItem = self.encodedItem(item), favs.contains(encodedItem) {
            removeFromFavorites(item: item)
        } else {
            addToFavorites(item: item)
        }
    }

    private func encodedItem(_ item: Item) -> Data? {
        return try? JSONEncoder().encode(item)
    }

    private func decodeItem(from data: Data) -> Item? {
        return try? JSONDecoder().decode(Item.self, from: data)
    }
}
