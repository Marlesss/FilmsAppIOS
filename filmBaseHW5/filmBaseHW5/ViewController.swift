//
//  ViewController.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 25.01.2023.
//

import UIKit
import Dispatch

// TODO: make password field
// TODO: make validators @IBInspectable
// TODO: add validators to TF
// TODO: show API errors
class ViewController: UIViewController {
    
    static public let serverAPI = ServerAPI()
    
    @IBOutlet private var loginTF: NamedTextField!
    @IBOutlet private var passwordTF: NamedTextField!
    @IBOutlet private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction
    private func login() {
        loginSuccessfully()
        return
        ViewController.serverAPI.login(login: loginTF.getData(), password: passwordTF.getData()) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.sync {
                    self.loginSuccessfully()
                }
            case let .failure(err):
                // TODO: color all red
                print(err)
            }
        }
    }
    
    private func loginSuccessfully() {
        let filmsTable = UIStoryboard(name: "FilmsTable", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(filmsTable, animated: true)
    }
}

