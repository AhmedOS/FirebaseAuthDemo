//
//  LoginVC.swift
//  FirebaseDemo
//
//  Created by Ahmed Osama on 10/15/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class LoginVC: UIViewController {
    
    // MARK: - Properties
    
    var handle: AuthStateDidChangeListenerHandle?
    var haveAccount = true
    var confirmPasswordLabel: UILabel?
    var confirmPasswordTextField: UITextField?
    let contriesVCSegueID = "showCountries"
    let animationDuration = 0.4
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        email.delegate = self
        password.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        password.text = ""
        setupListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(#selector(keyboardWillShow))
        NotificationCenter.default.removeObserver(#selector(keyboardWillHide))

        removeListener()
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if email.text == "" || password.text == "" || confirmPasswordTextField?.text == "" {
            showSimpleAlert(title: "Empty fields", message: "Fill all fields and try again")
            return
        }
        if haveAccount {
            logIn()
        }
        else {
            if password.text == confirmPasswordTextField?.text {
                signUp()
            }
            else {
                showSimpleAlert(title: "Confirm password", message: "Passwords aren't identical")
            }
        }
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        if haveAccount {
            setupForSignUp()
        }
        else {
            setupForLogIn()
        }
    }
    
    // MARK: - Helpers
    
    func setupListener() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: self.contriesVCSegueID, sender: self)
            }
        }
    }
    
    func removeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func setupForSignUp() {
        haveAccount = false
        
        confirmPasswordLabel = UILabel(frame: passwordLabel.frame)
        let cpl = confirmPasswordLabel!
        cpl.text = "Confirm Password"
        cpl.font = passwordLabel.font
        cpl.textAlignment = .center
        cpl.sizeToFit()
        cpl.alpha = 0
        view.insertSubview(cpl, belowSubview: password)
        
        confirmPasswordTextField = UITextField(frame: password.frame)
        let cptf = confirmPasswordTextField!
        cptf.delegate = self
        cptf.font = password.font
        cptf.borderStyle = .roundedRect
        cptf.isSecureTextEntry = true
        cptf.alpha = 0
        view.insertSubview(cptf, belowSubview: password)
        
        setTextsColors(color: signButton.backgroundColor!)
        fadeViews(fadeIn: true)
        
        signButton.setTitle("Sign Up", for: .normal)
        createAccountButton.setTitle("I have an account", for: .normal)
    }
    
    func setupForLogIn() {
        haveAccount = true
        setTextsColors(color: createAccountButton.backgroundColor!)
        fadeViews(fadeIn: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) {
            self.confirmPasswordLabel?.removeFromSuperview()
            self.confirmPasswordTextField?.removeFromSuperview()
            self.confirmPasswordLabel = nil
            self.confirmPasswordTextField = nil
        }
        
        signButton.setTitle("Log In", for: .normal)
        createAccountButton.setTitle("Create account", for: .normal)
    }
    
    func fadeViews(fadeIn: Bool) {
        let alpha: CGFloat = fadeIn ? 1 : 0
        let diff = (password.frame.origin.y - email.frame.origin.y) * (fadeIn ? 1 : -1)
        let y1 = (confirmPasswordLabel?.frame.origin.y)! + diff
        confirmPasswordLabel?.fade(y: y1, alphaValue: alpha, duration: animationDuration)
        let y2 = (confirmPasswordTextField?.frame.origin.y)! + diff
        confirmPasswordTextField?.fade(y: y2, alphaValue: alpha, duration: animationDuration)
    }
    
    func setTextsColors(color: UIColor) {
        emailLabel.textColor = color
        passwordLabel.textColor = color
        confirmPasswordLabel?.textColor = color
    }
    
    func logIn(){
        enableButtons(value: false)
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if let error = error {
                self.showSimpleAlert(title: "Failed to Log In", message: error.localizedDescription)
            }
            self.enableButtons(value: true)
        }
    }
    
    func signUp() {
        enableButtons(value: false)
        let parameters: Parameters = [
            "email": "\(email.text!)",
            "password": "\(password.text!)",
            "returnSecureToken": true
        ]
        Alamofire.request(API.signUpEndPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let status = response.response?.statusCode
            if status == 200, let json = response.result.value {
                self.processSignUpResponse(response: JSON(json))
            }
            else if let json = response.result.value {
                let message = JSON(json)["error"]["message"].string!
                self.showSimpleAlert(title: "Failed to Sign Up", message: message)
            }
            self.enableButtons(value: true)
        }
    }
    
    func processSignUpResponse(response: JSON) {
        let email = response["email"].string!
        let alert = UIAlertController(title: "Account created", message: "Log In with your email: \(email)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.setupForLogIn()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func enableButtons(value: Bool) {
        signButton.isEnabled = value
        createAccountButton.isEnabled = value
        if value {
            activityIndicator.stopAnimating()
        }
        else {
            activityIndicator.startAnimating()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let currentSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= targetSize.height - 100
        }
        else {
            self.view.frame.origin.y += currentSize.height - targetSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
}

// MARK: - UITextField Delegate

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
