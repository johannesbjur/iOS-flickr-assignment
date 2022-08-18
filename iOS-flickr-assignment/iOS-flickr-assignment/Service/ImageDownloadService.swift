//
//  ImageDownloadService.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-17.
//

import Foundation

private enum Constants {
    static let domain = "https://flickr.com"
    static let path = "/services/rest"
    static let apiKey = "&api_key=8fc9186e406bb7d0a9ddb9c9bbd0db2f"
    static let parameters = "?method=flickr.photos.search&tags=electrolux&per_page=20&page=1&format=json&extras=url_sq&nojsoncallback=true"
}

enum ImageDownloadError: Error {
    case urlParsingError
    case apiResponseError
    case imageParsingError
}

protocol ImageDownloadServiceProtocol {
    func fetchImageItems() async throws -> [ImageItem]
    func fetchImage(from url: URL) async throws -> Data
}

final class ImageDownloadService: ImageDownloadServiceProtocol {
    func fetchImageItems() async throws -> [ImageItem] {
        let urlString = Constants.domain + Constants.path + Constants.parameters + Constants.apiKey
        guard let url = URL(string: urlString) else { throw ImageDownloadError.urlParsingError }
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ImageDownloadError.apiResponseError
        }
        do {
            let imageItem = try JSONDecoder().decode(ImageResponse.self, from: data)
            return imageItem.photos.photo
        } catch {
            throw ImageDownloadError.imageParsingError
        }
    }

    func fetchImage(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ImageDownloadError.apiResponseError
        }
        return data
    }
}
