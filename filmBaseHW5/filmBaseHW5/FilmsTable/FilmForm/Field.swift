//
//  Field.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 25.01.2023.
//

import UIKit

protocol Field: UIControl {
    associatedtype DataType
    
    /// Cleans data
    func clean() -> Void
    
    /// Returns data
    func getData() -> DataType
    
    
    /// Is it true that data is valid
    func dataIsValid() -> Bool
}
