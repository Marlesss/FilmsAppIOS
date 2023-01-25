//
//  ViewController.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 25.01.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var myButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction
    private func doMake() {
        let filmsTable = UIStoryboard(name: "FilmsTable", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(filmsTable, animated: true)
    }

}

