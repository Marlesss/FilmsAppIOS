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
    static public let loadImageAPI = ServerAPI()
    
    public var currentUserToken: String?
    
    @IBOutlet private var loginTF: NamedTextField!
    @IBOutlet private var passwordTF: NamedTextField!
    @IBOutlet private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentUserToken = nil
    }
    
    @IBAction
    private func login() {
//        ViewController.serverAPI.login(login: loginTF.getData(), password: passwordTF.getData())
        ViewController.serverAPI.login(login: "admin", password: "123456")
        { result in
            switch result {
            case let .success(loginResponse):
                DispatchQueue.main.sync {
                    self.loginSuccessfully(loginResponse)
                }
            case let .failure(err):
                // TODO: color all red
                print(err)
            }
        }
    }
    
    private func loginSuccessfully(_ loginResponse: ServerAPI.LoginResponse) {
        currentUserToken = loginResponse.token
        let filmsTable = UIStoryboard(name: "FilmsTable", bundle: nil).instantiateInitialViewController() as! FilmsTable
        filmsTable.rootViewController = self
        self.navigationController?.pushViewController(filmsTable, animated: true)
    }
}

