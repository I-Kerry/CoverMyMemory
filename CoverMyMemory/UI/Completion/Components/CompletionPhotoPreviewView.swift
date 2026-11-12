//
//  CompletionPhotoPreviewView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 09.11.2026.
//

import SwiftUI
import PhotosUI

public struct CompletionPhotoPreviewView: View {
    private let photoData: Data?
    private let onCameraTap: () -> Void
    private let onRemoveTap: () -> Void
    @Binding private var selectedPhotoItem: PhotosPickerItem?
    
    public init(
        photoData: Data?,
        selectedPhotoItem: Binding<PhotosPickerItem?>,
        onCameraTap: @escaping () -> Void,
        onRemoveTap: @escaping () -> Void
    ) {
        self.photoData = photoData
        _selectedPhotoItem = selectedPhotoItem
        self.onCameraTap = onCameraTap
        self.onRemoveTap = onRemoveTap
    }
    
    public var body: some View {
        if let data = photoData, let uiImage = UIImage(data: data) {
            capturedPreview(image: uiImage)
        } else {
            emptyCaptureBox
        }
    }
    
    // MARK: - Captured Preview
    private func capturedPreview(image: UIImage) -> some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Radius.large, style: .continuous)
                        .stroke(Color.appCheckmarkGreen, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            
            HStack(spacing: Constants.Spacing.large) {
                Button(action: onCameraTap) {
                    Label("Retake", systemImage: AssetCatalog.Icons.camera)
                        .font(.appSubheadline)
                        .foregroundColor(.appAccent)
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Change", systemImage: AssetCatalog.Icons.photo)
                        .font(.appSubheadline)
                        .foregroundColor(.appAccent)
                }
                
                Button(role: .destructive, action: onRemoveTap) {
                    Label("Remove", systemImage: AssetCatalog.Icons.trash)
                        .font(.appSubheadline)
                        .foregroundColor(.appDestructive)
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.medium)
    }
    
    // MARK: - Empty Capture Viewport
    private var emptyCaptureBox: some View {
        VStack(spacing: Constants.Spacing.medium) {
            VStack(spacing: Constants.Spacing.small) {
                Circle()
                    .fill(Color.appAccent.opacity(0.12))
                    .frame(width: Constants.Layout.avatarSize, height: Constants.Layout.avatarSize)
                    .overlay(
                        Image(systemName: AssetCatalog.Icons.camera)
                            .font(.system(size: Constants.Layout.photoPickerIconSize, weight: .semibold))
                            .foregroundColor(.appAccent)
                    )
                
                Text("Confirm with Photo")
                    .font(.appHeadline)
                    .foregroundColor(.appTextPrimary)
                
                Text("Capture an image to remember this moment and confirm task completion.")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.large)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Radius.large, style: .continuous)
                    .strokeBorder(Color.appTextSecondary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
            
            HStack(spacing: Constants.Spacing.medium) {
                Button(action: onCameraTap) {
                    Label("Take Photo", systemImage: AssetCatalog.Icons.camera)
                        .font(.appButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.small)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.small, style: .continuous))
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Library", systemImage: AssetCatalog.Icons.photo)
                        .font(.appButton)
                        .foregroundColor(.appAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.small)
                        .background(Color.appAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.small, style: .continuous))
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.medium)
    }
}

#Preview {
   @Previewable @State var mockPhotoItem: PhotosPickerItem? = nil
    CompletionPhotoPreviewView(photoData: nil, selectedPhotoItem: $mockPhotoItem, onCameraTap: {}, onRemoveTap: {})
}
