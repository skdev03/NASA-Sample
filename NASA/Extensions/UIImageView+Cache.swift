import UIKit

class ImageCache: NSObject {
    static let shared = ImageCache()
    
    private override init() { }
    
    private let imageCache = NSCache<AnyObject, AnyObject>()
    
    func add(image: UIImage, for url: URL) {
        imageCache.setObject(image, forKey: url as AnyObject)
    }
    
    func image(for url: URL) -> UIImage? {
        imageCache.object(forKey: url as AnyObject) as? UIImage
    }
}

class ImageLoader {
    typealias Completion = (Result<UIImage, Error>) -> Void

    private var runningRequests: [UUID: URLSessionTask] = [:]

    func loadImage(with url: URL, completion: @escaping Completion) -> UUID? {
        if let cachedImage = ImageCache.shared.image(for: url) {
            completion(.success(cachedImage))
            return nil
        }

        let uuid = UUID()

        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            defer { self.runningRequests.removeValue(forKey: uuid) }

            if let data = data, let downloadedImage = UIImage(data: data) {
                ImageCache.shared.add(image: downloadedImage, for: url)
                completion(.success(downloadedImage))
                return
            }

            guard let error = error else {
                // without an image or an error, we'll just ignore this for now
                // you could add your own special error cases for this scenario
                return
            }

            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }

            // the request was cancelled, no need to call the callback
        }

        task.resume()
        runningRequests[uuid] = task
        return uuid
    }

    func cancelRequest(with uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

class UIImageLoader {
    static let shared = UIImageLoader()

    private var imageLoader = ImageLoader()
    private var imageViewMap: [UIImageView: UUID] = [:]

    private init() { }

    func loadImage(with url: URL, placeholder: UIImage? = nil, for imageView: UIImageView) {
        let token = imageLoader.loadImage(with: url) { result in
            defer { self.imageViewMap.removeValue(forKey: imageView) }

            do {
                let image = try result.get()

                DispatchQueue.main.async {
                    imageView.image = image
                }
            } catch {
                DispatchQueue.main.async {
                    imageView.image = placeholder
                }
            }
        }

        if let token = token {
            imageViewMap[imageView] = token
        }
    }

    func cancelLoading(for imageView: UIImageView) {
        if let uuid = imageViewMap[imageView] {
            imageLoader.cancelRequest(with: uuid)
            imageViewMap.removeValue(forKey: imageView)
        }
    }
}

extension UIImageView {
    func loadImage(with url: URL, placeholder: UIImage? = nil) {
        image = placeholder
        UIImageLoader.shared.loadImage(with: url, for: self)
    }

    func cancelImageLoading() {
        UIImageLoader.shared.cancelLoading(for: self)
    }
}
