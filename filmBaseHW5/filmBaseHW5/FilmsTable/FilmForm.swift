//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

import UIKit

// TODO: change tap event on imagePicker
class FilmForm: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public var filmsTable: FilmsTable?
    
    private lazy var scrollView: UIScrollView = {
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
    private lazy var fields: [any Field] = [imagePicker, filmNameNTF, producerNTF, yearNDF, starsMarker]
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
    private lazy var imagePicker: ImagePicker = {
        imagePicker = ImagePicker()
        imagePicker.addTarget(self, action: #selector(pickImage), for: .touchDown)
        return imagePicker
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Добавить фильм"
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        for subview in [scrollView, clearButton, saveButton] {
            view.addSubview(subview)
        }
        for subview in fields {
            scrollView.addSubview(subview)
        }
        
        for dataField in fields {
            dataField.addTarget(self, action: #selector(checkData), for: .editingChanged)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        self.view.addGestureRecognizer(tap)
        
        let safeLG = self.view.safeAreaLayoutGuide
        let contentView = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: safeLG.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            imagePicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            imagePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imagePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imagePicker.heightAnchor.constraint(equalToConstant: 172),
            
            filmNameNTF.topAnchor.constraint(equalTo: imagePicker.bottomAnchor, constant: 16),
            filmNameNTF.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            filmNameNTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            filmNameNTF.heightAnchor.constraint(equalToConstant: 72),
            
            producerNTF.topAnchor.constraint(equalTo: filmNameNTF.bottomAnchor, constant: 16),
            producerNTF.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            producerNTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            producerNTF.heightAnchor.constraint(equalToConstant: 72),
            
            yearNDF.topAnchor.constraint(equalTo: producerNTF.bottomAnchor, constant: 16),
            yearNDF.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            yearNDF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            yearNDF.heightAnchor.constraint(equalToConstant: 72),
            
            starsMarker.topAnchor.constraint(equalTo: yearNDF.bottomAnchor, constant: 48),
            starsMarker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            starsMarker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            starsMarker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            clearButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 32),
            clearButton.leadingAnchor.constraint(equalTo: safeLG.leadingAnchor, constant: 16),
            clearButton.trailingAnchor.constraint(equalTo: safeLG.trailingAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: safeLG.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: safeLG.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: safeLG.bottomAnchor)
        ])
    }
    
    @objc
    private func dismissMyKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc
    private func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.imagePicker.delegate = self
            imagePicker.imagePicker.sourceType = .photoLibrary
            imagePicker.imagePicker.allowsEditing = false
            
            present(imagePicker.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        var imageExtension: ImageExtension?
        if (info[.imageURL] as? URL)?.pathExtension == "png" {
            imageExtension = .PNG
        } else {
            imageExtension = .JPEG
        }
        imagePicker.setImage(newImage, imageExtension!)

        dismiss(animated: true)
        
    }
    
    @objc
    private func save() {
        assert(allDataIsValid())
        let filmData = FilmData(image: imagePicker.getData()!, filmName: filmNameNTF.getData(), producer: producerNTF.getData(), year: Int(yearNDF.getData())!, stars: starsMarker.getData()!)
        filmsTable?.saveFilm(filmData)
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
        fields
            .map { $0.dataIsValid() }
            .reduce(into: true) { $0 = $0 && $1 }
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
        fields.forEach { $0.clean() }
    }
    
}
