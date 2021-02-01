import UIKit

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.resueIdentifier)
    }
    
    func dequeReusableCell<T: UICollectionViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.resueIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(T.self)")
        }
        
        return cell
    }
}
