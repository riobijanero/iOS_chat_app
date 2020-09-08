//
//  DBProvider.swift
//  ChatApp
//
//  Created by Bijan on 09.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FetchData: class {
    func dataReceived(contacts: [Contact])
}

class DBProvider {
    
    private let
    STORAGE_REFERENCE_URL = "gs://chatapp-1ebc5.appspot.com",
    DATABASE_REFERENCE_URL = "https://chatapp-1ebc5.firebaseio.com/"
    
    
    private static let _instance = DBProvider()
    
    
    //"weak" means, the value wont be instatiated until it's needed
    weak var delegate: FetchData?
    
    //private constructor
    private init () {}
    
    static var Instance: DBProvider{
        return _instance
    }
    

    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var contactsRef: DatabaseReference {
        return dbRef.child(Constants.CONTATCS)
        
        // alternativ: return dbRef.child("contacts")
    }
    
    var messagesRef: DatabaseReference {
        return dbRef.child(Constants.MESSAGES)
    }
    
    var mediaMessagesRef: DatabaseReference {
        return dbRef.child(Constants.MEDIA_MESSAGES)
    }
    
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: STORAGE_REFERENCE_URL)
    }
    
    var imageStorageReference: StorageReference {
        return storageRef.child(Constants.IMAGE_STORAGE)
    }
    
    var videoStorageReference: StorageReference {
        return storageRef.child(Constants.VIDEO_STORAGE)
    }
    
    func saveUser(withID: String, email: String, password: String){
        /*dictionary. storing the user in our databse with 2 key value pairs:
        
        Key (String) : Value (Any)
        _____________________________
        "email"      : <email adress>
        "password"   : <password>
         */
        
        let userData: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD : password]
        
        //create another child in the DBreference with a uniqeID and set the value Data
        contactsRef.child(withID).setValue(userData)
    }
    
    
    func getContacts () {
        
        contactsRef.observeSingleEvent(of: DataEventType.value) {
            (snapshot: DataSnapshot) in
            var contacts = [Contact]()
            
            if let myContacts = snapshot.value as? NSDictionary {
                for (key, value) in myContacts {
                    
                    if let contactData = value as? NSDictionary {
                        
                        if let email = contactData[Constants.EMAIL] as? String {
                            
                            let id = key as! String
                            let newContact = Contact(id: id, name: email)
                            
                            contacts.append(newContact)
                            
                        }
                    }
                }
            }
            self.delegate?.dataReceived(contacts: contacts)
            //calling this function will cause every spot/class that confirms to the FetchData Protocol to call their own dataReceived function
        }

    }
    
    
    
    
    
    
} // class
