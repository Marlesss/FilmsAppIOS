//
//  NamedDateField.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

// TODO: Fix error caused by tap in the other TextField
// TODO: datepicker localization?????
// TODO: scantext permission denied ;(
class NamedDateField: NamedTextField {
    private lazy var datePicker: UIDatePicker = {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postInit()
    }
    
    private func postInit() {
        textField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePicked), for: .valueChanged)
    }
    
    @objc
    private func datePicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        textField.text = dateFormatter.string(from: datePicker.date)
        textField.sendActions(for: .editingChanged)
    }
    
    @objc
    private func cancelPicking() {
        textField.resignFirstResponder()
    }
}
