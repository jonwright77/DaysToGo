//
//  PhotoFetcher.swift
//  DaysToGo
//
//  Created by Jon Wright on 24/07/2025.
//

import Photos
import SwiftUI
import OSLog
import DaysToGoKit

class PhotoService: PhotoFetching {
    func requestAuthorization() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        
        let newStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard newStatus == .authorized || newStatus == .limited else {
            throw AppError.permissionDenied(service: "Photos")
        }
    }

    func fetchPhotos(from date: Date, maxCount: Int = 4) async throws -> [UIImage] {
        try await requestAuthorization()

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", start as NSDate, end as NSDate)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard assets.count > 0 else {
            return []
        }

        let total = min(maxCount, assets.count)
        // Take the first N photos sorted by creation date (newest first) for consistency
        let indices = Array(0..<total)
        
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var uiImages: [UIImage] = []
            
            for index in indices {
                let asset = assets.object(at: index)
                group.addTask {
                    return await withCheckedContinuation { continuation in
                        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
                            if let error = info?[PHImageErrorKey] as? Error {
                                AppLogger.photos.error("Error fetching image: \(error.localizedDescription)")
                                continuation.resume(returning: nil)
                            } else {
                                continuation.resume(returning: image)
                            }
                        }
                    }
                }
            }
            
            for try await image in group {
                if let image = image {
                    uiImages.append(image)
                }
            }
            
            return uiImages
        }
    }
}
