import Foundation
import Combine

class ItemsViewModel {
    private var subscriptions = Set<AnyCancellable>()

    /// Publisher containing the items that were received from the service.
    @Published var items: [Item]?

    /// Publisher containing the error when fetching items from the service.
    @Published var error: APIError?

    /// Publisher containing the text that was entered in the search bar.
    /// Listens to the changes from the search bar text updates.
    @Published var searchTerm: String = ""

    /// Maximum count of items that will be displayed in the view.
    private let maxItems = 15

    /// Contains the type of media (image or video).
    private let mediaType: MediaType
    
    private let service: SearchService
    private let persistenceManager: Favoritable

    init(service: SearchService, mediaType: MediaType, persistenceManager: Favoritable) {
        self.service = service
        self.mediaType = mediaType
        self.persistenceManager = persistenceManager

        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchTerm in
                self?.fetchItems(searchTerm: searchTerm)
            }
            .store(in: &subscriptions)
    }
    
    private func fetchItems(searchTerm: String) {
        guard !searchTerm.isEmpty else { return }
        
        service.search(searchTerm: searchTerm, mediaType: mediaType.rawValue)
            .sink (receiveCompletion: { [weak self] value in
                switch value {
                case .failure(let error):
                    self?.error = error
                    self?.items = []
                case .finished: break
                }
            }, receiveValue: { [weak self] items in
                guard let self = self else { return }
                self.items = Array(items.prefix(self.maxItems))
            }).store(in: &subscriptions)
    }

    /// Saves the item if it was not saved previously, otherwise unsaves the item.
    /// - Parameter item: Item to be saved.
    func toggleFavorite(for item: Item) {
        persistenceManager.toggleFavorite(for: item)
    }
}
