//
//  ImagePicker.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 26.01.2023.
//

import UIKit

public enum ImageExtension {
    case PNG
    case JPEG
}


// TODO: fix permission denied
// [AXRuntimeCommon] AX Lookup problem - errorCode:1100 error:Permission denied portName:'com.apple.iphone.axserver' PID:1544
public class ImagePicker: UIControl, Field {
    typealias DataType = (UIImage, ImageExtension)?

    private lazy var imageView: UIImageView = {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var defaultLabel: UILabel = {
        defaultLabel = UILabel(frame: .zero)
        defaultLabel.text = "Добавить постер"
        defaultLabel.font = .systemFont(ofSize: 16)
        defaultLabel.textAlignment = .center
        defaultLabel.backgroundColor = .systemGray3
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        return defaultLabel
    }()
    
    public let imagePicker = UIImagePickerController()
    private var imageExtension: ImageExtension?
    
    init() {
        super.init(frame: .zero)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }
    
    private func initSubviews() {
        addSubview(imageView)
        addSubview(defaultLabel)
        
        showImage(false)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            defaultLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            defaultLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            defaultLabel.topAnchor.constraint(equalTo: topAnchor),
            defaultLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    public func setImage(_ image: UIImage, _ imageExtension: ImageExtension) {
        imageView.image = image
        self.imageExtension = imageExtension
        showImage(true)
        sendActions(for: .editingChanged)
    }
    
    func getData() -> DataType {
        if let image = imageView.image, let imageExtension = self.imageExtension {
            return (image, imageExtension)
        }
        return nil
    }
    
    func clean() {
        imageView.image = nil
        showImage(false)
    }
    
    func dataIsValid() -> Bool {
        imageView.image != nil && !imageView.isHidden
    }
    
    private func showImage(_ bool: Bool) {
        imageView.isHidden = !bool
        defaultLabel.isHidden = bool
    }
    
}
