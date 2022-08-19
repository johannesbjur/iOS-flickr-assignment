//
//  ImageSaver.swift
//  iOS-flickr-assignment
//
//  Created by Johannes Bjurströmer on 2022-08-19.
//

import Foundation
import UIKit

final class ImageSaver: NSObject {
    private var completion: (() -> Void)?

    func saveToPhotoAlbum(image: UIImage, completion: @escaping () -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

     @objc private func saveCompleted() {
        guard let completion = completion else { return }
        completion()
    }
}
