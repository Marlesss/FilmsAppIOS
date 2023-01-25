//
//  Validator.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import Foundation

class Validator {
    private let validateFunc: (String) -> Bool
    init(validateFunc: @escaping (String) -> Bool) {
        self.validateFunc = validateFunc
    }
    
    public func validate(text: String) -> Bool {
        return validateFunc(text)
    }
    
    static func && (left: Validator, right: Validator) -> Validator {
        return Validator { text in left.validate(text: text) && right.validate(text: text)}
    }
    
    static func || (left: Validator, right: Validator) -> Validator {
        return Validator { text in left.validate(text: text) || right.validate(text: text)}
    }
}
