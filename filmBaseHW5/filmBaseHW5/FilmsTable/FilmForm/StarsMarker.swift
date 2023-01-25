//
//  StarsMarker.swift
//  ios-itmo-2022-assignment2
//
//  Created by Алексей Щербаков on 21.10.2022.
//

import UIKit

class StarsMarker: UIControl {
    private var starsRow: StarsRow
    private lazy var textMark: UILabel = {
        textMark = UILabel()
        textMark.text = "Ваша оценка"
        textMark.font = .systemFont(ofSize: 16)
        textMark.translatesAutoresizingMaskIntoConstraints = false
        return textMark
    }()

    
    init(frame: CGRect, n: Int) {
        starsRow = StarsRow(n: n)
        super.init(frame: frame)
        
        addSubview(textMark)
        addSubview(starsRow)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        starsRow.addTarget(self, action: #selector(setTextMark), for: .editingChanged)
        
        var consntraints: [NSLayoutConstraint] = []
        
        consntraints.append(contentsOf: [
            NSLayoutConstraint(item: starsRow, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: starsRow, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: starsRow, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textMark, attribute: .top, relatedBy: .equal, toItem: starsRow, attribute: .bottom, multiplier: 1, constant: 24),
            NSLayoutConstraint(item: textMark, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textMark, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
        ])
        
        NSLayoutConstraint.activate(consntraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getMark() -> Int? {
        return starsRow.getMark()
    }
    
    public func clearData() {
        setMark(mark: nil)
    }
    
    public func setMark(mark: Int?) {
        starsRow.setMark(mark: mark)
        setTextMark()
    }
        
    @objc
    private func setTextMark() {
        let mark = getMark()
        if let mark = mark {
            textMark.text = ["Ужасно", "Плохо", "Нормально", "Хорошо", "Гениально!"][min(mark, 5) - 1]
        } else {
            textMark.text = "Ваша оценка"
        }
        sendActions(for: .editingChanged)
    }

}
