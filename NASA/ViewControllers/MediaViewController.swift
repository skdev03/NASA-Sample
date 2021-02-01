import UIKit
import Combine

/// View controller for showing image and video items for a search term.
class MediaViewController: UIViewController {
    typealias SearchDataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias SearchSnapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var subscriptions = Set<AnyCancellable>()
    private let service = NASASearchService()
    private var items: [Item] = []
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        return searchController
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .white
        collectionView.registerCell(MediaCell.self)
        return collectionView
    }()
    
    lazy var dataSource: SearchDataSource = {
        SearchDataSource(collectionView: collectionView) { (_, indexPath, item) in
            self.configure(with: item, at: indexPath)
        }
    }()
    
    private let viewModel: ItemsViewModel

    init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupViews()
        
        collectionView.dataSource = dataSource
        setupBindings()
    }

}

extension MediaViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTerm = searchController.searchBar.text!
    }
}

extension MediaViewController {
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout.init { (section, env) -> NSCollectionLayoutSection? in
            let itemFraction: CGFloat = (UIScreen.main.bounds.width < UIScreen.main.bounds.height) ? 0.5 : 1/3
            
            // The item's height is equal to the item's width.
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(itemFraction), heightDimension: .fractionalWidth(itemFraction)))
            item.contentInsets.trailing = 4
            item.contentInsets.bottom = 8
            
            // The group's width is equal to the section's width.
            // The group's height has an estimated value of 200.
            // The group will resize based on the number on items in the datasource.
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 4, bottom: 0, trailing: 0)
            
            return section
        }
    }
    
    private func setupBindings() {
        viewModel.$items
            .filter { $0 != nil }
            .sink { [weak self] items in
                guard let items = items else { return }
                self?.items = items
                self?.applySnapshot()
            }.store(in: &subscriptions)
    }

    private func setupViews() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addConstrained(subview: collectionView, toSafeArea: true)
    }
    
    private func configure(with item: Item, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaCell = collectionView.dequeReusableCell(MediaCell.self, for: indexPath)
        cell.render(item: items[indexPath.row])

        cell.longTap
            .filter { $0 == item }
            .sink { self.viewModel.toggleFavorite(for: $0) }
            .store(in: &subscriptions)

        return cell
    }
    
    private func applySnapshot() {
        var snapshot = SearchSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension MediaViewController {
    enum Section {
        case main
    }
}
