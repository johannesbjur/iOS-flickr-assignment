//
//  ImageCollectionPresenter.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-18.
//

import Foundation
import UIKit

protocol ImageCollectionPresenterProtocol {
    func viewDidLoad() async
    func saveImageToPhotoAlbum(image: UIImage)
    func searchImages(with string: String) async
}

final class ImageCollectionPresenter: ImageCollectionPresenterProtocol {
    private var imageDownloadService: ImageDownloadServiceProtocol
    private weak var viewDelegate: ImageCollectionViewControllerProtocol?
    
    init(imageDownloadService: ImageDownloadServiceProtocol, viewDelegate: ImageCollectionViewControllerProtocol) {
        self.imageDownloadService = imageDownloadService
        self.viewDelegate = viewDelegate
    }

    func viewDidLoad() async {
        await fetchImages(with: "electrolux")
    }

    func saveImageToPhotoAlbum(image: UIImage) {
        let imageSaver = ImageSaver(delegate: self)
        imageSaver.saveToPhotoAlbum(image: image)
    }

    func searchImages(with string: String) async {
        await fetchImages(with: string)
    }
}

// MARK: - Private functions
private extension ImageCollectionPresenter {
    func fetchImages(with string: String) async {
        do {
            for imageItem in try await imageDownloadService.fetchImageItems(with: string) {
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
            viewDelegate?.showReloadError(with: message)
        } catch {
            viewDelegate?.showReloadError(with: "Generic error")
        }
    }
}

// MARK: - ImageSaverDelegate functions
extension ImageCollectionPresenter: ImageSaverDelegate {
    func saveComplete(error: Error?) {
        if error != nil {
            viewDelegate?.showAlert(with: "Error", message: "Failed to save image")
        } else {
            viewDelegate?.showAlert(with: "Image saved", message: "Images has been saved to your photo library")
        }
    }
}
