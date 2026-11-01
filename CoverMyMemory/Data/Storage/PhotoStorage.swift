//
//  PhotoStorage.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import UIKit

public protocol PhotoStorage: AnyObject {
    func savePhoto(_ image: UIImage) async throws -> (fileName: String, thumbnailData: Data)
    func loadPhoto(fileName: String) async -> UIImage?
    func deletePhoto(fileName: String) async throws
    func deleteAllPhotos() async throws
}
