//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

import UIKit

class FilmForm: UIViewController {
    public var mainView: MainView?
    private let lengthFrom1To300 = Validator(validateFunc: { text in return (1...300).contains(text.count) })
    private let lengthFrom3To300 = Validator(validateFunc: { text in return (3...300).contains(text.count) })
    private let charsInRuOrEngAlph = Validator(validateFunc: { text in text.lowercased().allSatisfy({ char in "a" <= char && char <= "z" || "а" <= char && char <= "я" || char == " "}) })
    private let wordsStartsInUpperCase = Validator(validateFunc: { text in text.split(separator: " ").allSatisfy({ word in word.first?.isUppercase ?? false }) })
    private let dateFormat = Validator(validateFunc: { text in text.range(of: "[0-9]{2}.[0-9]{2}.[0-9]{4}", options: .regularExpression)?.lowerBound == text.startIndex && text.range(of: "[0-9]{2}.[0-9]{2}.[0-9]{4}", options: .regularExpression)?.upperBound == text.endIndex })
    private let yearFormat = Validator(validateFunc: {text in text.allSatisfy({char in char.isNumber})})
    
    
    private lazy var label: UILabel = {
        label = UILabel()
        label.text = "Фильм"
        label.font = .boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var filmNameNTF = NamedTextField(frame: .zero,
                                                  name: "Название",
                                                  textField: MyTextField(frame: .zero, placeholder: "Название фильма"),
                                                  validator: lengthFrom1To300)
    private lazy var producerNTF = NamedTextField(frame: .zero,
                                                  name: "Режиссёр",
                                                  textField: MyTextField(frame: .zero, placeholder: "Режиссёр фильма"),
                                                  validator: lengthFrom3To300 && charsInRuOrEngAlph && wordsStartsInUpperCase)
    private lazy var yearNTF = NamedDateField(frame: .zero,
                                              name: "Год",
                                              textField: MyTextField(frame: .zero, placeholder: "Год выпуска"),
                                              validator: yearFormat)
    private let starsMarker = StarsMarker(frame: CGRect(), n: 5)
    private lazy var saveButton: UIButton = {
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.layer.cornerRadius = 25
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        setSaveButtonMode(isEnabled: false)
        return saveButton
    }()
    private lazy var clearButton: UIButton = {
        clearButton = UIButton(type: .system)
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.backgroundColor = .lightGray
        clearButton.layer.cornerRadius = 25
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearData), for: .touchUpInside)
        return clearButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        for subview in [label, filmNameNTF, producerNTF, yearNTF, starsMarker, saveButton, clearButton] {
            view.addSubview(subview)
        }
        
        for dataField in [filmNameNTF, producerNTF, yearNTF, starsMarker] {
            dataField.addTarget(self, action: #selector(checkData), for: .editingChanged)
        }
        
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            filmNameNTF.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40),
            filmNameNTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filmNameNTF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            producerNTF.topAnchor.constraint(equalTo: filmNameNTF.bottomAnchor, constant: 16),
            producerNTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            producerNTF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            yearNTF.topAnchor.constraint(equalTo: producerNTF.bottomAnchor, constant: 16),
            yearNTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            yearNTF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            starsMarker.topAnchor.constraint(equalTo: yearNTF.bottomAnchor, constant: 48),
            starsMarker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            clearButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            clearButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            clearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc
    private func save() {
        guard let mark = starsMarker.getMark() else {return}
        let filmData = FilmData(filmName: filmNameNTF.getText(), producer: producerNTF.getText(), year: Int(yearNTF.getText())!, stars: mark)
        mainView?.saveFilm(filmData)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func checkData() {
        if (allDataIsValide()) {
            setSaveButtonMode(isEnabled: true)
        } else {
            setSaveButtonMode(isEnabled: false)
        }
    }
    
    private func allDataIsValide() -> Bool {
        for field in [filmNameNTF, producerNTF, yearNTF] {
            if (!field.dataIsValid()) {
                return false
            }
        }
        if (starsMarker.getMark() == -1) {
            return false
        }
        return true
    }
    
    
    private func setSaveButtonMode(isEnabled: Bool) {
        if (isEnabled) {
            saveButton.isEnabled = true
            saveButton.layer.opacity = 1
        } else {
            saveButton.isEnabled = false
            saveButton.layer.opacity = 0.4
        }
    }
    
    @objc
    private func clearData() {
        // TODO: make common protocol
        for field in [filmNameNTF, producerNTF, yearNTF] {
            field.clearData()
        }
        starsMarker.clearData()
    }
    
}
