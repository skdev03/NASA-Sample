import UIKit
import Combine

/// Represents a cell of `MediaViewController's` collection view.
/// Long tap gesture on this cell is used to save or unsave the video item.
class MediaCell: UICollectionViewCell {

    private let longTapPublisher: PassthroughSubject<Item, Never> = PassthroughSubject()
    var longTap: AnyPublisher<Item, Never> { longTapPublisher.share().eraseToAnyPublisher() }

    private let titleLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private var canHandleLongTap: Bool = false
    private var item: Item?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addConstrained(subview: imageView)
        addConstrained(subview: titleLabelContainer, top: nil, left: 0, bottom: 0, right: 0)
        titleLabelContainer.addConstrained(subview: titleLabel, top: 4, left: 4, bottom: -4, right: -4)

        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(gestureRecognizer:)))
        addGestureRecognizer(longTapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        imageView.cancelImageLoading()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func render(item: Item) {
        guard let itemData = item.data.first else { return }

        canHandleLongTap = (itemData.mediaType == .video)
        self.item = item

        let previewImage = item.links?.filter { $0.rel == "preview" }.first?.href
        let encodedImageLink = previewImage?.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters)
        
        if let previewImageLink = encodedImageLink, let imageUrl = URL(string: previewImageLink) {
            titleLabel.text = itemData.title
            imageView.loadImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "dark-moon"))
        }
    }

    @objc private func longTap(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began, canHandleLongTap else { return }

        guard let item = item else { return }
        longTapPublisher.send(item)
    }
}

extension MediaCell {
    enum Action {
        case toggleFavorite(Item)
    }
}
