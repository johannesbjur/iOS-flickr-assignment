//
//  ImageCollectionViewController.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-17.
//

import UIKit

protocol ImageCollectionViewControllerProtocol: AnyObject {
    func addImageDataToCollectionView(imageData: Data)
    func showReloadError(with message: String)
    func showAlert(with title: String, message: String)
}

final class ImageCollectionViewController: UIViewController {
    private var images: [UIImage] = []
    private var selectedCellIndex: Int?

    private let imageCollectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: UICollectionViewFlowLayout())
    private let searchController = UISearchController(searchResultsController: nil)
    private var presenter: ImageCollectionPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ImageCollectionPresenter(imageDownloadService: ImageDownloadService(),
                                                  viewDelegate: self)
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
        
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

    func showReloadError(with message: String) {
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

    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
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

    func setupNavigationBar() {
        title = "Flickr Photos"
        let navBarApp = UINavigationBarAppearance()
        navigationController?.navigationBar.scrollEdgeAppearance = navBarApp
        navigationController?.navigationBar.backgroundColor = .white

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(saveCellImage))
    }

    func setupSearchBar() {
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    @objc func saveCellImage() {
        guard let selectedCellIndex = selectedCellIndex,
              images.indices.contains(selectedCellIndex) else { return }
        presenter?.saveImageToPhotoAlbum(image: images[selectedCellIndex])
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
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

// MARK: - Search controller delegate functions
extension ImageCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        images = []
        imageCollectionView.reloadData()
        Task {
            await presenter?.searchImages(with: searchText)
        }
    }
}
