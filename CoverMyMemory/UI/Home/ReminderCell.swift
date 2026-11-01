//
//  ReminderCell.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import UIKit

public final class ReminderCell: UITableViewCell {
    public static let reuseIdentifier = "ReminderCell"
    
    public var onThumbnailTap: ((Data) -> Void)?
    public var onCheckmarkTap: (() -> Void)?
    
    private let containerCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Radius.large
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.Radius.avatar
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let personNameLabel: UILabel = {
        let label = UILabel()
        label.font = .appSubheadline
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appCardTitle
        label.textColor = .appTextPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .appCaption
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.Radius.small
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var currentThumbnailData: Data?
    
    private var contentTrailingToContainerConstraint: NSLayoutConstraint?
    private var contentTrailingToThumbnailConstraint: NSLayoutConstraint?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerCardView)
        
        containerCardView.addSubview(avatarImageView)
        containerCardView.addSubview(personNameLabel)
        containerCardView.addSubview(timeLabel)
        containerCardView.addSubview(titleLabel)
        containerCardView.addSubview(statusLabel)
        containerCardView.addSubview(checkmarkButton)
        containerCardView.addSubview(thumbnailImageView)
        
        // Tap gesture on thumbnail
        let thumbTap = UITapGestureRecognizer(target: self, action: #selector(didTapThumbnail))
        thumbnailImageView.addGestureRecognizer(thumbTap)
        
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmark), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.cardGap / 2),
            containerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            containerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            containerCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.cardGap / 2),
            
            avatarImageView.topAnchor.constraint(equalTo: containerCardView.topAnchor, constant: Constants.Spacing.medium),
            avatarImageView.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor, constant: Constants.Spacing.medium),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.avatarSize),
            
            personNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            personNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.Spacing.small),
            
            timeLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: personNameLabel.leadingAnchor),
            
            checkmarkButton.topAnchor.constraint(equalTo: containerCardView.topAnchor, constant: Constants.Spacing.medium),
            checkmarkButton.trailingAnchor.constraint(equalTo: containerCardView.trailingAnchor, constant: -Constants.Spacing.medium),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 28),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.Spacing.small),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Spacing.xSmall),
            statusLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: containerCardView.bottomAnchor, constant: -Constants.Spacing.medium),
            
            thumbnailImageView.trailingAnchor.constraint(equalTo: containerCardView.trailingAnchor, constant: -Constants.Spacing.medium),
            thumbnailImageView.bottomAnchor.constraint(equalTo: containerCardView.bottomAnchor, constant: -Constants.Spacing.medium),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: Constants.Layout.thumbnailSize),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: Constants.Layout.thumbnailSize)
        ])
        
        contentTrailingToContainerConstraint = titleLabel.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -Constants.Spacing.small)
        contentTrailingToThumbnailConstraint = titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -Constants.Spacing.small)
        
        contentTrailingToContainerConstraint?.isActive = true
    }
    
    public func configure(with item: ReminderItem) {
        self.currentThumbnailData = item.photoThumbData
        
        titleLabel.text = item.title
        personNameLabel.text = item.personName.map { "For \($0)" } ?? "For You"
        
        if let time = item.timeFormatted {
            timeLabel.text = item.isCompleted ? time : "\(time) · Today"
        } else {
            timeLabel.text = "All day"
        }
        
        if let thumbData = item.personThumbData, let image = UIImage(data: thumbData) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: AssetCatalog.Icons.person)
            avatarImageView.tintColor = .appAccent
        }
        
        if item.isCompleted {
            containerCardView.backgroundColor = .appCardCompleted
            
            let checkConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
            let checkImage = UIImage(systemName: AssetCatalog.Icons.checkmarkCircle, withConfiguration: checkConfig)?
                .withTintColor(.appCheckmarkGreen, renderingMode: .alwaysOriginal)
            checkmarkButton.setImage(checkImage, for: .normal)
            
            if item.hasPhoto, let photoData = item.photoThumbData, let thumb = UIImage(data: photoData) {
                thumbnailImageView.image = thumb
                thumbnailImageView.isHidden = false
                
                statusLabel.text = "Attached file 📎"
                statusLabel.textColor = .appTextGreen
                
                contentTrailingToContainerConstraint?.isActive = false
                contentTrailingToThumbnailConstraint?.isActive = true
            } else {
                thumbnailImageView.isHidden = true
                statusLabel.text = "Completed today"
                statusLabel.textColor = .appTextGreen
                
                contentTrailingToThumbnailConstraint?.isActive = false
                contentTrailingToContainerConstraint?.isActive = true
            }
        } else {
            containerCardView.backgroundColor = .appCardBackground
            thumbnailImageView.isHidden = true
            
            let circleConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
            let circleImage = UIImage(systemName: AssetCatalog.Icons.circle, withConfiguration: circleConfig)?
                .withTintColor(UIColor.systemGray4, renderingMode: .alwaysOriginal)
            checkmarkButton.setImage(circleImage, for: .normal)
            
            statusLabel.text = item.deadlineText ?? "No deadline"
            statusLabel.textColor = .appTextSecondary
            
            contentTrailingToThumbnailConstraint?.isActive = false
            contentTrailingToContainerConstraint?.isActive = true
        }
    }
    
    @objc private func didTapCheckmark() {
        onCheckmarkTap?()
    }
    
    @objc private func didTapThumbnail() {
        if let data = currentThumbnailData {
            onThumbnailTap?(data)
        }
    }
}
