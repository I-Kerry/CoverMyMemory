//
//  FilePhotoStorage.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import UIKit

public final class FilePhotoStorage: PhotoStorage {
    
    private let fileManager = FileManager.default
    private let photosDirectoryURL: URL
    
    public init() {
//        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
//        self.photosDirectoryURL = appSupport.appendingPathComponent(Constants.Storage.photosDirectoryName, isDirectory: true)
//        createDirectoryIfNeeded()
        
        do {
            let appSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.photosDirectoryURL = appSupport.appendingPathComponent(Constants.Storage.photosDirectoryName, isDirectory: true)
            createDirectoryIfNeeded()
        } catch {
            fatalError("Failed access to the Directory: \(error)")
        }
    }
    
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: photosDirectoryURL.path) {
            try? fileManager.createDirectory(at: photosDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public func savePhoto(_ image: UIImage) async throws -> (fileName: String, thumbnailData: Data) {
        createDirectoryIfNeeded()
        
        let uuid = UUID().uuidString
        let fileName = "\(uuid).jpg"
        let fileURL = photosDirectoryURL.appendingPathComponent(fileName)
        
        // 1. Save full resolution JPEG
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "FilePhotoStorage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"])
        }
        
        try jpegData.write(to: fileURL, options: .atomic)
        
        // 2. Generate thumbnail Data (64pt @2x = 128x128px)
        let thumbnail = generateThumbnail(from: image, targetSize: CGSize(width: Constants.Layout.thumbnailSize * 2, height: Constants.Layout.thumbnailSize * 2))
        guard let thumbData = thumbnail.jpegData(compressionQuality: 0.75) else {
            throw NSError(domain: "FilePhotoStorage", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to generate thumbnail"])
        }
        
        return (fileName, thumbData)
    }
    
    public func loadPhoto(fileName: String) async -> UIImage? {
        let fileURL = photosDirectoryURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    public func deletePhoto(fileName: String) async throws {
        let fileURL = photosDirectoryURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public func deleteAllPhotos() async throws {
        if fileManager.fileExists(atPath: photosDirectoryURL.path) {
            let files = try fileManager.contentsOfDirectory(atPath: photosDirectoryURL.path)
            for file in files {
                let fileURL = photosDirectoryURL.appendingPathComponent(file)
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    // MARK: - Thumbnail Generation
    private func generateThumbnail(from image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            let aspectWidth = targetSize.width / image.size.width
            let aspectHeight = targetSize.height / image.size.height
            let aspectRatio = max(aspectWidth, aspectHeight)
            
            let scaledWidth = image.size.width * aspectRatio
            let scaledHeight = image.size.height * aspectRatio
            let originX = (targetSize.width - scaledWidth) / 2.0
            let originY = (targetSize.height - scaledHeight) / 2.0
            
            image.draw(in: CGRect(x: originX, y: originY, width: scaledWidth, height: scaledHeight))
        }
    }
}
