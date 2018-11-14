//
//  LoginViewController.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-11-07.
//

import UIKit
import FirebaseAuth
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if  Auth.auth().currentUser != nil {
            present(MapViewController(), animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func setupUI() {
        logoImageView.addBorder(color: nil, width: nil, cornerRadius: 5)
        logoImageView.layer.masksToBounds = true
        emailTextField.selectedTitleColor = UIColor(named: "theme-blue")!
        emailTextField.selectedLineColor = UIColor(named: "theme-blue")!
        passwordTextField.selectedTitleColor = UIColor(named: "theme-blue")!
        passwordTextField.selectedLineColor = UIColor(named: "theme-blue")!
        loginButton.addBorder(color: nil, width: nil, cornerRadius: 20)
    }
    
    @IBAction func didPressLoginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if user != nil {
                self.present(MapViewController(), animated: true, completion: nil)
            } else {
                print("Sign in failed")
            }
        }
    }
    
    @IBAction func didPressSignUpButton(_ sender: Any) {
        present(SignUpViewController(), animated: true, completion: nil)
    }
    

}
