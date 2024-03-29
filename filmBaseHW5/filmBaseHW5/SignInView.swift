import UIKit
import Dispatch

// TODO: make password field
// TODO: make validators @IBInspectable
// TODO: show API errors
// TODO: passwordTF secure text entry
// TODO: make load-image-tasks cancellable through return dispatchqueue
// TODO: end up SignUpVC
// TODO: add colors in white/black theme
// TODO: add localization
// TODO: think about FilmCell design
// TODO: add image loading sign in FilmCell
// TODO: make an ending of register with API request
// TODO: add validation of login/password/email fields
// TODO: enable login requests
// TODO: use keychain services to keep login session
// TODO: add pagination loading of films
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
//                        ViewController.serverAPI.login(login: loginTF.getData(), password: passwordTF.getData())
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

