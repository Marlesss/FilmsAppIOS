//
//  StarButton.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class StarButton: UIButton {
    static let starOffImage = UIImage(named: "Star")
    static let starOnImage = UIImage(named: "Union")
    public let i: Int
    init(frame: CGRect, i: Int) {
        self.i = i
        super.init(frame: frame)
        setImage(StarButton.starOffImage, for: .normal)
        setImage(StarButton.starOnImage, for: .highlighted)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
