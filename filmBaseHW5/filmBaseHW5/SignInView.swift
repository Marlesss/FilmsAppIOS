import UIKit
import Dispatch

// TODO: make password field
// TODO: make validators @IBInspectable
// TODO: add validators to TF
// TODO: show API errors
// TODO: passwordTF secure text entry
// TODO: make load-image-tasks cancellable through return dispatchqueue
// TODO: make NTF designable (show it on storyboard)
class SignInView: UIViewController {
    
    static public let serverAPI = ServerAPI()
    static public let loadImageAPI = ServerAPI()
    
    public var currentUserToken: String?
    
    @IBOutlet private var loginTF: NamedTextField!
    @IBOutlet private var passwordTF: NamedTextField!
    private var loginInProcess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentUserToken = nil
    }
    
    private func signIn() -> Bool {
        guard !loginInProcess else {return false}
        loginInProcess = true
        //                ViewController.serverAPI.login(login: loginTF.getData(), password: passwordTF.getData())
        SignInView.serverAPI.login(login: "admin", password: "123456")
        { result in
            DispatchQueue.main.sync {
                switch result {
                case let .success(loginResponse):
                    self.currentUserToken = loginResponse.token
                case let .failure(err):
                    // TODO: color all red
                    print(err)
                }
                self.loginInProcess = false
            }
        }
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while loginInProcess
        return currentUserToken != nil
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmsTable = segue.destination as? FilmsTable {
            filmsTable.rootViewController = self
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showFilmsTable" {
            return signIn()
        }
        return true
    }
}

