//
//  SignUpViewController.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-11-14.
//

import UIKit
import FirebaseAuth
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func didPressCreateAccountButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard authResult?.user != nil else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didPressCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        emailTextField.selectedTitleColor = UIColor(named: "theme-blue")!
        emailTextField.selectedLineColor = UIColor(named: "theme-blue")!
        passwordTextField.selectedTitleColor = UIColor(named: "theme-blue")!
        passwordTextField.selectedLineColor = UIColor(named: "theme-blue")!
        confirmPasswordTextField.selectedTitleColor = UIColor(named: "theme-blue")!
        confirmPasswordTextField.selectedLineColor = UIColor(named: "theme-blue")!
        createAccountButton.addBorder(color: nil, width: nil, cornerRadius: 20)
    }

}
