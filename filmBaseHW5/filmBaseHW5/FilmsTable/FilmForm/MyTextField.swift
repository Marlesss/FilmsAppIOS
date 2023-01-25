//
//  MyTextField.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class MyTextField: UITextField {
    static private let padding: CGFloat = 16
    
    init(frame: CGRect, placeholder: String) {
        super.init(frame: frame)
        
        font = .systemFont(ofSize: 16)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        self.placeholder = placeholder
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + MyTextField.padding, y: bounds.minY, width: bounds.width - MyTextField.padding * 2, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + MyTextField.padding, y: bounds.minY, width: bounds.width - MyTextField.padding * 2, height: bounds.height)
    }
}
