//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

import UIKit

class FilmForm: UIViewController {
    public var mainView: MainView?
    
    private lazy var headerLabel: UILabel = {
        headerLabel = UILabel()
        headerLabel.text = "Фильм"
        headerLabel.font = .boldSystemFont(ofSize: 30)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .center
        return headerLabel
    }()
    private lazy var filmNameNTF = NamedTextField(frame: .zero,
                                                  name: "Название",
                                                  textField: MyTextField(frame: .zero, placeholder: "Название фильма"),
                                                  validator: Validator.lengthFrom1To300)
    private lazy var producerNTF = NamedTextField(frame: .zero,
                                                  name: "Режиссёр",
                                                  textField: MyTextField(frame: .zero, placeholder: "Режиссёр фильма"),
                                                  validator: Validator.lengthFrom3To300 && Validator.charsInRuOrEngAlph && Validator.wordsStartsInUpperCase)
    private lazy var yearNDF = NamedDateField(frame: .zero,
                                              name: "Год",
                                              textField: MyTextField(frame: .zero, placeholder: "Год выпуска"),
                                              validator: Validator.yearFormat)
    private lazy var starsMarker = StarsMarker(frame: .zero, n: 5)
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
        clearButton.addTarget(self, action: #selector(cleanData), for: .touchUpInside)
        return clearButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        for subview in [headerLabel, filmNameNTF, producerNTF, yearNDF, starsMarker, saveButton, clearButton] {
            view.addSubview(subview)
        }
        
        for dataField in [filmNameNTF, producerNTF, yearNDF, starsMarker] {
            dataField.addTarget(self, action: #selector(checkData), for: .editingChanged)
        }
        
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            filmNameNTF.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 40),
            filmNameNTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filmNameNTF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            producerNTF.topAnchor.constraint(equalTo: filmNameNTF.bottomAnchor, constant: 16),
            producerNTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            producerNTF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            yearNDF.topAnchor.constraint(equalTo: producerNTF.bottomAnchor, constant: 16),
            yearNDF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            yearNDF.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            starsMarker.topAnchor.constraint(equalTo: yearNDF.bottomAnchor, constant: 48),
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
        assert(allDataIsValid())
        let filmData = FilmData(filmName: filmNameNTF.getData(), producer: producerNTF.getData(), year: Int(yearNDF.getData())!, stars: starsMarker.getData()!)
        mainView?.saveFilm(filmData)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func checkData() {
        if (allDataIsValid()) {
            setSaveButtonMode(isEnabled: true)
        } else {
            setSaveButtonMode(isEnabled: false)
        }
    }
    
    private func allDataIsValid() -> Bool {
        [filmNameNTF, producerNTF, yearNDF, starsMarker]
            .map { field in (field as? (any Field))?.dataIsValid() ?? false }
            .reduce(into: true) { partialResult, bool in partialResult = partialResult && bool }
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
    private func cleanData() {
        [filmNameNTF, producerNTF, yearNDF, starsMarker]
            .forEach { field in
                (field as? (any Field))?.clean()
            }
    }
    
}
