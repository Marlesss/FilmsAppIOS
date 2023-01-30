//
//  Validator.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import Foundation

class Validator {
    class Everything: Validator {
        init() {
            super.init { _ in true }
        }
    }
    
    static public let lengthFrom1To4 = Validator(validateFunc: { text in return (1...4).contains(text.count) })
    static public let lengthFrom1To300 = Validator(validateFunc: { text in return (1...300).contains(text.count) })
    static public let lengthFrom3To300 = Validator(validateFunc: { text in return (3...300).contains(text.count) })
    static public let charsInRuOrEngAlph = Validator(validateFunc: { text in text.lowercased().allSatisfy({ char in "a" <= char && char <= "z" || "а" <= char && char <= "я" || char == " "}) })
    static public let wordsStartsInUpperCase = Validator(validateFunc: { text in text.split(separator: " ").allSatisfy({ word in word.first?.isUppercase ?? false }) })
    static public let dateFormat = Validator(validateFunc: { text in text.range(of: "[0-9]{2}.[0-9]{2}.[0-9]{4}", options: .regularExpression)?.lowerBound == text.startIndex && text.range(of: "[0-9]{2}.[0-9]{2}.[0-9]{4}", options: .regularExpression)?.upperBound == text.endIndex })
    static public let yearFormat = Validator(validateFunc: {text in text.allSatisfy({char in char.isNumber})}) && lengthFrom1To4
    
    
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
