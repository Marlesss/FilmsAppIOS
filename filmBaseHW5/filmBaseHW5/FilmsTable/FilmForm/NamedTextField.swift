//
//  NamedTextField.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class NamedTextField : UIControl, Field {
    typealias DataType = String
    
    private lazy var label: UILabel = {
        label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: MyTextField
    private let validator: Validator
    
    init(frame: CGRect, name: String, textField: MyTextField, validator: Validator = Validator.Everything()) {
        self.textField = textField
        self.validator = validator
        
        super.init(frame: frame)
        initSubviews(name: name)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews(name: String) {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        addSubview(textField)
        label.text = name
        paint(stateIsNormal: true)
        
        textField.addTarget(self, action: #selector(validateData), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.heightAnchor.constraint(equalToConstant: 15),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -8),
            
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    @objc
    public func validateData() {
        paint(stateIsNormal: dataIsValid())
    }
    
    func clean() {
        textField.text = ""
        paint(stateIsNormal: true)
    }
    
    func getData() -> DataType {
        textField.text ?? ""
    }
    
    func dataIsValid() -> Bool {
        validator.validate(text: getData())
    }
    
    
    private func paint(stateIsNormal: Bool) {
        if (stateIsNormal) {
            label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
            textField.layer.borderColor = CGColor(gray: 232/255, alpha: 1)
        } else {
            label.textColor = .systemRed
            textField.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
        textField.addTarget(target, action: action, for: controlEvents)
    }
}
