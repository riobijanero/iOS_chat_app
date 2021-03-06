//
//  MessagesHandler.swift
//  ChatApp
//
//  Created by Bijan on 13.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class {
    func messageReceived(senderID: String, senderName: String, text: String)
    func mediaReceived(senderID: String, senderName: String, url: String)
}

class MessagesHandler {
    
    private static let _instance = MessagesHandler()
    private init(){}
    
    weak var delegate: MessageReceivedDelegate?
    
    static var Instance: MessagesHandler {
        return _instance
    }
    
    func sendMessage (senderID: String, senderName: String, text: String) {
        let data: Dictionary<String, Any> =
            //key                //value
            //-----------------------------
            [Constants.SENDER_ID: senderID,
             Constants.SENDER_NAME: senderName,
             Constants.TEXT: text]
    
        DBProvider.Instance.messagesRef.childByAutoId().setValue(data)
    
    }
    
    func sendMediaMessage(senderID: String, senderName: String, url: String) {
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.URL: url]
        
        DBProvider.Instance.mediaMessagesRef.childByAutoId().setValue(data)
    }
    
    // ---changed something here from .put -> putData
    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String) {
        
        if image != nil {
            //image is provided. so send image
            
            //create the child in the storage reference and upload it there and output the path to the metadata (url)
            DBProvider.Instance.imageStorageReference.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) { (metadata: StorageMetadata?, err: Error?)
                in
                
                if err != nil {
                    print(" ----- problem uplading the image -------")
                } else {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String (describing: metadata!.downloadURL()!))
                }
            }
        } else if video != nil {
            
            DBProvider.Instance.videoStorageReference.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata: StorageMetadata?, err: Error?) in
                
                if err != nil {
                     print(" ----- problem uplading the video -------")
                } else {
                    
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String (describing: metadata!.downloadURL()!))
                }
            }
        }
    }
    
    func observeMessages() {
        DBProvider.Instance.messagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let text = data[Constants.TEXT] as? String {
                            self.delegate?.messageReceived(senderID: senderID, senderName: senderName, text: text)

                        }
                    }
                }
            }
        }
    }
    
    
    func observeMediaMessages () {
        // DBProvider.Instance.mediaMessagesRef because we are saving our data in de mediaMessagesReference
        DBProvider.Instance.mediaMessagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
        
            //check if the snapshot value is of type dictionary
            if let data = snapshot.value as? NSDictionary {
                //if true, get the id
                if let senderID = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let fileURL = data[Constants.URL] as? String {
                            self.delegate?.mediaReceived(senderID: senderID, senderName: senderName, url: fileURL)
                        }
                    }
                    
                }
                
            }
            
        }
    }










} // class
