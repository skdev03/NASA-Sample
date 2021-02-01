import UIKit
import Combine

/// View controller for showing Image and Video category cells.
class CategoriesViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MediaType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MediaType>

    /// Publisher for sending an action to the `MainCoordinator` when a category cell is selected.
    let actionPublisher: PassthroughSubject<MainCoordinator.Action, Never>
    
    private var items: [MediaType] = [.image, .video]
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.registerCell(CategoryCell.self)
        return collectionView
    }()
    
    lazy var dataSource: DataSource = {
        DataSource(collectionView: collectionView) { (_, indexPath, item) in
            self.configure(with: item, at: indexPath)
        }
    }()
    
    init(actionPublisher: PassthroughSubject<MainCoordinator.Action, Never>) {
        self.actionPublisher = actionPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "NASA"
        view.backgroundColor = .white
        view.addConstrained(subview: collectionView)
        applySnapshot()
    }

}

extension CategoriesViewController {
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
    
    private func configure(with item: MediaType, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCell = collectionView.dequeReusableCell(CategoryCell.self, for: indexPath)
        cell.render(item: items[indexPath.row])
        return cell
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension CategoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        actionPublisher.send(.categorySelected(item))
    }
}

extension CategoriesViewController {
    enum Section {
        case main
    }
}
