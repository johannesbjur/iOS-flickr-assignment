//
//  ImageSaver.swift
//  iOS-flickr-assignment
//
//  Created by Tove Jansson on 2022-08-19.
//

import Foundation
import UIKit

protocol ImageSaverDelegate {
    func saveComplete(error: Error?)
}

final class ImageSaver: NSObject {
    private var delegate: ImageSaverDelegate

    init(delegate: ImageSaverDelegate) {
        self.delegate = delegate
    }

    func saveToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        delegate.saveComplete(error: error)
    }
}
