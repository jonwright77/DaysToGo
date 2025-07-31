//
//  PhotoFetcher.swift
//  DaysToGo
//
//  Created by Jon Wright on 24/07/2025.
//


import Photos
import SwiftUI

class PhotoFetcher {
    static func fetchPhotos(from date: Date, maxCount: Int = 4, completion: @escaping ([UIImage]) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                completion([])
                return
            }

            let calendar = Calendar.current
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", start as NSDate, end as NSDate)

            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var uiImages: [UIImage] = []
            let imageManager = PHImageManager.default()

            let total = min(maxCount, assets.count)
            let indices = Array(0..<assets.count).shuffled().prefix(total)

            let group = DispatchGroup()

            for index in indices {
                group.enter()
                let asset = assets.object(at: index)
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = false

                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                    if let image = image {
                        uiImages.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(uiImages)
            }
        }
    }
}
