import Foundation
import UIKit
import Combine

/// Class for managing the navigation and presentation of views.
class MainCoordinator {
    var subscriptions = Set<AnyCancellable>()
    var window: UIWindow
    var navigationController: UINavigationController?

    /// Publisher for receiving the actions from different views.
    var actionPublisher: PassthroughSubject<Action, Never> = PassthroughSubject()
    
    init(window: UIWindow) {
        self.window = window
        
        actionPublisher.sink { action in
            self.handleAction(action: action)
        }.store(in: &subscriptions)
    }
    
    func handleAction(action: Action) {
        switch action {
        case .categorySelected(let mediaType):
            showMediaView(for: mediaType)
        }
    }
    
    func showMediaView(for mediaType: MediaType) {
        let itemsViewModel = ItemsViewModel(service: NASASearchService(), mediaType: mediaType, persistenceManager: PersistenceManager())
        let mediaVC = MediaViewController(viewModel: itemsViewModel)
        navigationController?.pushViewController(mediaVC, animated: true)
    }

    func start() {
        let categoriesVC = CategoriesViewController(actionPublisher: actionPublisher)
        navigationController = UINavigationController(rootViewController: categoriesVC)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension MainCoordinator {
    enum Action {
        case categorySelected(MediaType)
    }
}


