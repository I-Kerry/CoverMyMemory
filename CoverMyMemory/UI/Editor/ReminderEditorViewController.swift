//
//  ReminderEditorViewController.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 06.11.2026.
//

import SwiftUI

@MainActor
public final class ReminderEditorViewController: UIHostingController<ReminderEditorView> {
    
    public var onDismissOrSaved: (() -> Void)? {
        didSet {
            rootView.onDismissOrSaved = { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onDismissOrSaved?()
                }
            }
        }
    }
    
    public init(viewModel: ReminderEditorViewModel) {
        let editorView = ReminderEditorView(viewModel: viewModel)
        super.init(rootView: editorView)
        
        self.rootView.onDismissOrSaved = { [weak self] in
            self?.dismiss(animated: true) {
                self?.onDismissOrSaved?()
            }
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

#Preview {
    ReminderEditorViewController(viewModel: ReminderEditorViewModel())
}
