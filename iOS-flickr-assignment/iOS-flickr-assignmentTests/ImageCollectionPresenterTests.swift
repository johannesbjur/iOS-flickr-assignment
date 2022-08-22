//
//  ImageCollectionPresenterTests.swift
//  iOS-flickr-assignmentTests
//
//  Created by Johannes Bjurströmer on 2022-08-17.
//

import XCTest
@testable import iOS_flickr_assignment

final class ImageCollectionPresenterTests: XCTestCase {
    var presenter: ImageCollectionPresenterProtocol!
    private var mockService: MockService!
    private var mockViewController: MockViewController!
    
    override func setUp() {
        super.setUp()
        mockService = MockService()
        mockViewController = MockViewController()
        presenter = ImageCollectionPresenter(imageDownloadService: mockService,
                                             viewDelegate: mockViewController)
    }
    
    override func tearDown() {
        super.tearDown()
        presenter = nil
        mockService = nil
        mockViewController = nil
    }

    func testPresenter_serviceReturnsImageData_shouldCallAddToCollectionView() async {
        await presenter.viewDidLoad()
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertEqual(mockService.fetchImageItemsString, "electrolux")
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertTrue(mockViewController.addImageDataToCollectionViewCalled)
    }

    func testPresenter_serviceReturnsImageData_shouldReturnImagesWithSearchString() async {
        await presenter.searchImages(with: "testString")
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertEqual(mockService.fetchImageItemsString, "testString")
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertTrue(mockViewController.addImageDataToCollectionViewCalled)
    }

    func testPresenter_serviceReturnsImageDownloadError_shouldShowErrorMessage() async {
        mockService.fetchImageDataError = ImageDownloadError.urlParsingError
        await presenter.viewDidLoad()
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertEqual(mockViewController.errorMessage, "Url parsing error")
    }

    func testPresenter_serviceReturnsGenericError_shouldShowGenericError() async {
        mockService.fetchImageDataError = MockError.genericError
        await presenter.viewDidLoad()
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertEqual(mockViewController.errorMessage, "Generic error")
    }
}

private enum MockError: Error {
    case genericError
}

private final class MockService: ImageDownloadServiceProtocol {
    var fetchImageItemsCalled: Bool = false
    var fetchImageItemsString: String = ""
    var fetchImageDataCalled: Bool = false
    var fetchImageDataError: Error?

    func fetchImageItems(with string: String) async throws -> [ImageItem] {
        fetchImageItemsString = string
        fetchImageItemsCalled = true
        return [ImageItem(id: "1", title: "test", url_sq: "urlstring")]
    }
    
    func fetchImageData(from url: URL) async throws -> Data {
        fetchImageDataCalled = true
        if let fetchImageDataError = fetchImageDataError {
            throw fetchImageDataError
        }
        return Data()
    }
}

private final class MockViewController: ImageCollectionViewControllerProtocol {
    var errorMessage: String = ""
    var addImageDataToCollectionViewCalled: Bool = false

    func addImageDataToCollectionView(imageData: Data) {
        addImageDataToCollectionViewCalled = true
    }

    func showReloadError(with message: String) {
        errorMessage = message
    }

    func showAlert(with title: String, message: String) {
        errorMessage = message
    }
}
