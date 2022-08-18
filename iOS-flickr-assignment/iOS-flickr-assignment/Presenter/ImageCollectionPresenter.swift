//
//  ImageCollectionPresenter.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-18.
//

import Foundation

protocol ImageCollectionPresenterProtocol {
    func viewDidLoad() async
}

final class ImageCollectionPresenter: ImageCollectionPresenterProtocol {
    private var imageDownloadService: ImageDownloadService
    private weak var viewDelegate: ImageCollectionViewControllerProtocol?
    
    init(imageDownloadService: ImageDownloadService, viewDelegate: ImageCollectionViewControllerProtocol) {
        self.imageDownloadService = imageDownloadService
        self.viewDelegate = viewDelegate
    }

    func viewDidLoad() async {
        do {
            for imageItem in try await imageDownloadService.fetchImageItems() {
                guard let urlString = imageItem.url_sq,
                      let url = URL(string: urlString) else { continue }
                let imageData = try await imageDownloadService.fetchImageData(from: url)
                viewDelegate?.addImageDataToCollectionView(imageData: imageData)
            }
        } catch let error as ImageDownloadError {
            let message: String
            switch error {
            case .urlParsingError:
                message = "Url parsing error"
            case .apiResponseError:
                message = "Api response error"
            case .imageParsingError:
                message = "Image Parsing error"
            }
            viewDelegate?.showError(with: message)
        } catch {
            viewDelegate?.showError(with: "Generic error")
        }
    }
}
