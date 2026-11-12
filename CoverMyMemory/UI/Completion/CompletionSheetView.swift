//
//  CompletionSheetView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 11.11.2026.
//

import SwiftUI
import PhotosUI

public struct CompletionSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State public var viewModel: CompletionSheetViewModel
    @State private var showingCameraPicker = false
    @State private var showingCameraPermissionAlert = false
    @State private var capturedCameraImage: UIImage? = nil
    @State private var selectedPhotoLibraryItem: PhotosPickerItem? = nil
    
    public var onCompleted: (() -> Void)?
    
    public init(
        reminderId: UUID,
        targetDate: Date = Date(),
        viewModel: CompletionSheetViewModel? = nil,
        onCompleted: (() -> Void)? = nil
    ) {
        self.onCompleted = onCompleted
        _viewModel = State(wrappedValue: viewModel ?? CompletionSheetViewModel(reminderId: reminderId, targetDate: targetDate))
    }
    
    public var body: some View {
        NavigationStack {
            mainScrollContent
                .navigationTitle("Complete Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .task {
                    await viewModel.loadData()
                }
                .fullScreenCover(isPresented: $showingCameraPicker) {
                    cameraPickerSheet
                }
                .alert("Camera Access Required", isPresented: $showingCameraPermissionAlert) {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Please enable camera access in Settings to capture photo proof when completing reminders.")
                }
                .onChange(of: capturedCameraImage) { _, newImage in
                    handleCameraImage(newImage)
                }
                .onChange(of: selectedPhotoLibraryItem) { _, newItem in
                    handlePhotoLibraryItem(newItem)
                }
        }
    }
    
    // MARK: - Modular Content
    private var mainScrollContent: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.large) {
                headerSection
                photoSection
                actionButtonsSection
            }
            .padding(.vertical, Constants.Spacing.medium)
        }
    }
    
    // MARK: - Subviews
    private var headerSection: some View {
        CompletionTaskHeaderView(
            title: viewModel.reminderTitle,
            personName: viewModel.person?.name,
            personThumbData: viewModel.person?.photoThumbData,
            formattedDate: viewModel.formattedDateString,
            formattedTime: viewModel.formattedTimeString
        )
    }
    
    private var photoSection: some View {
        CompletionPhotoPreviewView(
            photoData: viewModel.capturedPhotoData,
            selectedPhotoItem: $selectedPhotoLibraryItem,
            onCameraTap: {
                showingCameraPicker = true
            },
            onRemoveTap: {
                viewModel.removePhoto()
            }
        )
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: Constants.Spacing.small) {
            Button(action: {
                completeTask(withPhoto: viewModel.hasCapturedPhoto)
            }) {
                HStack(spacing: Constants.Spacing.xSmall) {
                    Image(systemName: AssetCatalog.Icons.checkmarkCircle)
                        .fontWeight(.semibold)
                    
                    Text(viewModel.hasCapturedPhoto ? "Save & Complete" : "Complete Task")
                        .font(.appButton)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.medium)
                .background(Color.appCheckmarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.medium, style: .continuous))
                .shadow(color: Color.appCheckmarkGreen.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .disabled(viewModel.isSaving)
            .padding(.horizontal, Constants.Spacing.medium)
            
            if viewModel.hasCapturedPhoto {
                Button(action: {
                    completeTask(withPhoto: false)
                }) {
                    Text("Complete Without Photo")
                        .font(.appSubheadline)
                        .foregroundColor(.appTextSecondary)
                        .padding(.vertical, Constants.Spacing.xSmall)
                }
                .disabled(viewModel.isSaving)
            }
        }
        .padding(.top, Constants.Spacing.xSmall)
    }
    
    // MARK: - Toolbar & Sheets
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    private var cameraPickerSheet: some View {
        CameraPickerView(selectedImage: $capturedCameraImage, sourceType: .camera)
            .ignoresSafeArea()
    }
    
    // MARK: - Action Handlers
    private func requestCameraAccessAndOpen() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showingCameraPicker = true
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showingCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        self.showingCameraPicker = true
                    }
                }
            }
        case .denied, .restricted:
            showingCameraPermissionAlert = true
        @unknown default:
            showingCameraPicker = true
        }
    }
    
    private func handleCameraImage(_ image: UIImage?) {
        guard let image = image, let data = image.jpegData(compressionQuality: 0.85) else { return }
        viewModel.setPhotoData(data)
    }
    
    private func handlePhotoLibraryItem(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                viewModel.setPhotoData(data)
            }
        }
    }
    
    private func completeTask(withPhoto: Bool) {
        Task {
            do {
                try await viewModel.completeReminder(withPhoto: withPhoto)
                onCompleted?()
                dismiss()
            } catch {
            }
        }
    }
}

#Preview {
    CompletionSheetView(reminderId: UUID(), targetDate: Date(), viewModel: CompletionSheetViewModel(reminderId: UUID()), onCompleted: {})
}
