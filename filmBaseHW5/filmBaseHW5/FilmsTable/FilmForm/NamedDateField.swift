//
//  NamedDataField.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class NamedDateField: NamedTextField {
    private let textField: MyTextField
    private lazy var dtpckr: UIDatePicker = {
        dtpckr = UIDatePicker()
        dtpckr.datePickerMode = .date
        dtpckr.preferredDatePickerStyle = .wheels
        return dtpckr
    }()
    private lazy var toolBar: UIToolbar = {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicking))
        toolBar.setItems([done, flexibleSpace, cancel], animated: true)
        return toolBar
    }()

    override init(frame: CGRect, name: String, textField: MyTextField, validator: Validator) {
        self.textField = textField
        super.init(frame: frame, name: name, textField: textField, validator: validator)
        textField.inputView = dtpckr
        textField.inputAccessoryView = toolBar
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func datePicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        textField.text = dateFormatter.string(from: dtpckr.date)
        validateData()
        textField.resignFirstResponder()
        sendActions(for: .editingChanged)
    }

    @objc
    private func cancelPicking() {
        textField.resignFirstResponder()
    }
}
