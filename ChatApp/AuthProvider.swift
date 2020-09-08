//
//  AuthProvider.swift
//  ChatApp
//
//  Created by Bijan on 08.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginErrorCodeMessages  {
    
    static let INVALID_EMAIL = "Invalid Email, Pease provide a real Email adress"
    static let WRONG_PASSWORD = "Wrong password, please enter the correct password"
    static let PROBLEM_CONNECTING = "Problem connecting to database"
    static let USER_NOT_FOUND = "User not found, please register"
    static let EMAIL_ALREADY_IN_USE = " Email already in use, please use another email"
    static let WEAK_PASWORD = "Password should be at least 6 characters long"
    
}

//singleton pattern
class AuthProvider {
    
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    var userName = ""
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
                
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            
            } else {
                //send out without message because there is no error
                loginHandler?(nil)
            }
            
        }
    } //login func
    
    
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
             
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                
                //check if the User has his own user id
                if user?.uid != nil {
                    //if yes, user is created
                    
                    
                    //store the user in the databse 
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    //login the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        }
    } //signUp func
    
    
    func isLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
    
        return false
    }
    
    func logOut() -> Bool {
        
        //check if current user is valid / signed in
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            } catch {
                print("Problem Signing out the user")
                return false
            }
        }
        return true
    }
    
    func userID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    
    
    private func handleErrors (err: NSError, loginHandler: LoginHandler?) {
        
        //convert / parse the errorcode into a Firebase errorcode
        if let errCode = AuthErrorCode(rawValue: err.code){
            
            switch errCode {
                
            case .wrongPassword:
                //put the .wrongPassword-errorCode into the loginHandler and pass the USER_NOT_FOUND message
                loginHandler?(LoginErrorCodeMessages.WRONG_PASSWORD)
            
            case .invalidEmail:
                loginHandler?(LoginErrorCodeMessages.INVALID_EMAIL)
                
            case .userNotFound:
                loginHandler?(LoginErrorCodeMessages.USER_NOT_FOUND)
                
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCodeMessages.EMAIL_ALREADY_IN_USE)
                
            case .weakPassword:
                loginHandler?(LoginErrorCodeMessages.WEAK_PASWORD)
            
            default:
                loginHandler?(LoginErrorCodeMessages.PROBLEM_CONNECTING)
            }
            
        }
    }
    
} // class

