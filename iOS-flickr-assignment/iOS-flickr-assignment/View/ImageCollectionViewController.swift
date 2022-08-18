//
//  ImageCollectionViewController.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-17.
//

import UIKit

protocol ImageCollectionViewControllerProtocol: UIViewController {
    func addImageDataToCollectionView(imageData: Data)
    func showError(with message: String)
}

final class ImageCollectionViewController: UIViewController {
    private var images: [UIImage] = []
    private let imageCollectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: UICollectionViewFlowLayout())
    private var presenter: ImageCollectionPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ImageCollectionPresenter(imageDownloadService: ImageDownloadService(),
                                                  viewDelegate: self)
        setupCollectionView()
        Task {
            await presenter?.viewDidLoad()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageCollectionView.frame = view.bounds
    }
}
// MARK: - ImageCollectionViewControllerProtocol functions
extension ImageCollectionViewController: ImageCollectionViewControllerProtocol {
    func addImageDataToCollectionView(imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        images.append(image)
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
    }

    func showError(with message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Reload", style: .default) { [weak self] _ in
            Task {
                await self?.presenter?.viewDidLoad()
            }
        })
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Private functions
private extension ImageCollectionViewController {
    func setupCollectionView() {
        imageCollectionView.register(ImageCollectionViewCell.self,
                                     forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.backgroundColor = UIColor.gray
        view.addSubview(imageCollectionView)
    }
}

// MARK: - Collection view functions
extension ImageCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                           for: indexPath)
        guard let cell = cell as? ImageCollectionViewCell else { return cell }
        cell.configure(with: images[indexPath.row])
        return cell
    }
}

// MARK: - Collection view layout functions
extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96,
                      height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
}
