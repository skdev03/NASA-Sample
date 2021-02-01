import UIKit

protocol ReusableView {
    static var resueIdentifier: String { get }
}

extension ReusableView {
    static var resueIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }

extension UICollectionViewCell: ReusableView { }
