//
//  StarsRow.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class StarsRow: UIControl, Field {
    typealias DataType = Int?
    
    private let n: Int
    private var stars: [StarButton] = []
    private var mark: Int?
    
    init(n: Int) {
        self.n = n
        super.init(frame: .zero)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        self.n = 5
        super.init(coder: coder)
        initSubviews()
    }
    
    private func initSubviews() {
        for i in 0..<n {
            stars.append(StarButton(frame: .zero, i: i))
            addSubview(stars[i])
            stars[i].addTarget(self, action: #selector(chooseStar), for: .touchDown)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        var consntraints: [NSLayoutConstraint] = []
        consntraints.append(NSLayoutConstraint(item: stars[0], attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        consntraints.append(NSLayoutConstraint(item: stars[n - 1], attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        for i in 0..<n {
            consntraints.append(NSLayoutConstraint(item: stars[i], attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            consntraints.append(NSLayoutConstraint(item: stars[i], attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        }
        for i in 0..<(n - 1) {
            consntraints.append(NSLayoutConstraint(item: stars[i], attribute: .right, relatedBy: .equal, toItem: stars[i + 1], attribute: .left, multiplier: 1, constant: -12))
            consntraints.append(NSLayoutConstraint(item: stars[i], attribute: .width, relatedBy: .equal, toItem: stars[n - 1], attribute: .width, multiplier: 1, constant: 0))
            consntraints.append(NSLayoutConstraint(item: stars[i], attribute: .height, relatedBy: .equal, toItem: stars[n - 1], attribute: .height, multiplier: 1, constant: 0))
        }
        
        NSLayoutConstraint.activate(consntraints)
    }
    
    @objc
    private func chooseStar(_ sender: StarButton) {
        setMark(mark: sender.i + 1)
        sendActions(for: .editingChanged)
    }
    
    func clean() {
        setMark(mark: nil)
    }
    
    func getData() -> Int? {
        mark
    }
    
    func dataIsValid() -> Bool {
        mark != nil
    }
    
    public func setMark(mark: Int?) {
        guard let mark = mark else {
            self.mark = nil
            for i in 0..<n {
                stars[i].setImage(StarButton.starOffImage, for: .normal)
            }
            return
        }
        guard (1...n).contains(mark) else {
            print("Wrong mark was set. Waited for one of (1...\(n)), got \(mark)")
            return
        }
        self.mark = mark
        paintStars()
    }
    
    private func paintStars() {
        guard let mark = mark else {return}
        for i in 0..<n {
            stars[i].setImage(StarButton.starOffImage, for: .normal)
        }
        for i in 0..<mark {
            stars[i].setImage(StarButton.starOnImage, for: .normal)
        }
    }
}
