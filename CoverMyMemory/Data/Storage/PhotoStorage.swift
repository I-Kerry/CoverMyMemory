//
//  PhotoStorage.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import UIKit

public protocol PhotoStorage: AnyObject {
    /// Saves raw image data to Application Support/Photos/<UUID>.jpg
    /// Returns: (fileName, thumbnailData)
    func savePhoto(_ image: UIImage) async throws -> (fileName: String, thumbnailData: Data)
    
    /// Loads the full image from Application Support/Photos/<fileName>
    func loadPhoto(fileName: String) async -> UIImage?
    
    /// Deletes the photo file from Application Support/Photos/<fileName>
    func deletePhoto(fileName: String) async throws
    
    /// Deletes all photos in the Photos directory
    func deleteAllPhotos() async throws
}
