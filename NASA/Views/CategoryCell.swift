import UIKit

class CategoryCell: UICollectionViewCell {
    private let titleLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addConstrained(subview: imageView)
        addConstrained(subview: titleLabelContainer, top: 0, left: 0, bottom: nil, right: 0)
        titleLabelContainer.addConstrained(subview: titleLabel, top: 4, left: 4, bottom: -4, right: -4)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func render(item: MediaType) {
        titleLabel.text = item.title
        imageView.image = item.image
    }
}

extension MediaType {
    var title: String? {
        switch self {
        case .image:
            return "Images"
        case .video:
            return "Videos"
        default: break
        }

        return nil
    }

    var image: UIImage? {
        switch self {
        case .image:
            return #imageLiteral(resourceName: "images")
        case .video:
            return #imageLiteral(resourceName: "videos")
        default: break
        }

        return nil
    }
}
