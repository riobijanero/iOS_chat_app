
//
//  SignInVC.swift
//  ChatApp
//
//  Created by Bijan on 07.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    private let CONTACTS_SEGUE = "ContactsSegue"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //if user is logged in or didn't log out, then go straight to contactVC
    override func viewDidAppear(_ animated: Bool) {
        if AuthProvider.Instance.isLoggedIn(){
            performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)
        }
    }
    

    //triggered when login button is pressed on SignInVC
    @IBAction func login(_ sender: AnyObject) {
        
        //check if email and Password field are filled out by the user
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                //get back message. If there is an error, the message will have content i.e. != nil
                if message != nil {
                    self.alertTheUser(title: "Problem with Authentication", message: message!)
                
                //no message so no error
                } else {
                    print ("-------Login Completed---------")
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)
                }
            })
            
        }else{
            self.alertTheUser(title: "Missing Login Data", message: "please fill out all fields... seriously, what's worng with you?")
        }
        
        //performSegue(withIdentifier: CONTACTS_SEGUE, sender: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        //check if email and Password field are filled out by the user
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {
                (message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem with Creating a new User", message: message!)
                    
                } else {
                    
                    print ("----Sign Up Completed------")
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)
                }
            })
        } else{
            self.alertTheUser(title: "Missing Login Data", message: "please fill out all fields... seriously, what's worng with you?")
        }
        
    }
    
    private func alertTheUser(title: String, message: String){
        
        //create an alert message and button
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        
        //present the alert to the user
        present(alert, animated: true, completion: nil)
    }
    
   
    
    /*
    //validate email adress
    private func isValidEmail(testStr: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }*/
    
}//class
