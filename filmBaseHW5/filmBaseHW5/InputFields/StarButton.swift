//
//  StarButton.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

@IBDesignable
class StarButton: UIButton {
    static let starOffImage = UIImage(named: "StarOff")
    static let starOnImage = UIImage(named: "StarOn")
    @IBInspectable private var off: UIImage?
    @IBInspectable public var i: Int = 0
    init(frame: CGRect, i: Int) {
        self.i = i
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defer {
            postInit()
        }
    }
    
    private func postInit() {
        setImage(StarButton.starOffImage, for: .normal)
        setImage(StarButton.starOnImage, for: .highlighted)
    }
}
