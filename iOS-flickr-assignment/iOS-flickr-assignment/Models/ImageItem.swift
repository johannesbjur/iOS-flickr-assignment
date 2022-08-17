//
//  PhotoItem.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-17.
//

struct ImageResponse: Decodable {
    let photos: Images
    let stat: String
}

struct Images: Decodable {
    let photo: [ImageItem]
}

struct ImageItem: Decodable {
    let id: String
    let title: String
    let url_sq: String?
}
