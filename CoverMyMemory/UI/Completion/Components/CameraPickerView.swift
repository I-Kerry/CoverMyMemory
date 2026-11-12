//
//  CameraPickerView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 09.11.2026.
//

import SwiftUI

public struct CameraPickerView: UIViewControllerRepresentable {
    @Binding public var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    public var sourceType: UIImagePickerController.SourceType = .camera
    
    public init(
        selectedImage: Binding<UIImage?>,
        sourceType: UIImagePickerController.SourceType = .camera
    ) {
        _selectedImage = selectedImage
        self.sourceType = sourceType
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    @Previewable @State var selectedImage: UIImage? = nil
    CameraPickerView(selectedImage: $selectedImage, sourceType: .camera)
}
