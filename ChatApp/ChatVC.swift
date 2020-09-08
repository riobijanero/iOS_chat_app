//
//  ChatVC.swift
//  ChatApp
//
//  Created by Bijan on 12.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices //allows picking media from phone
import AVKit
import SDWebImage //allows us to download images in a seperate thread

class ChatVC: JSQMessagesViewController, MessageReceivedDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var messages = [JSQMessage]()
    
    private let messageBubbleColorOutgoing = UIColor.cyan
    private let messageBubbleColorIncoming = UIColor.blue
    private let profileImage = "profileIMG"
    private let profileImageDiameter = UInt(30)
    
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        MessagesHandler.Instance.delegate = self

        self.senderId = AuthProvider.Instance.userID()
        self.senderDisplayName = AuthProvider.Instance.userName
        
        MessagesHandler.Instance.observeMessages()
        MessagesHandler.Instance.observeMediaMessages()
        
        
        
        // Do any additional setup after loading the view.

    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Collection View functions -------
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        //test if the message is outgoing or incoming
        //if WE are the sender 
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: messageBubbleColorOutgoing)
        } else {//we are the receiver
            return bubbleFactory?.incomingMessagesBubbleImage(with: messageBubbleColorIncoming)
        }
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: profileImage), diameter: profileImageDiameter)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    // play videos in message bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        //get the selcted message bubble
        let msg = messages[indexPath.item]
        
        if msg.isMediaMessage {
            if let mediaItem = msg.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true, completion: nil)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    // END Collection View functions -----------
    
    
    // SENDING BUTTON FUNCTIONS ---------
    
    //for sending MESSAGES
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        /*messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()*/
        
        MessagesHandler.Instance.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text)
        
        //remove text from text field
        finishSendingMessage()
    }
    
    // for sending IMAGES / Videos
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select a media type", preferredStyle: .actionSheet)
        
        //cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage)
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeMovie)
        })
        
        alert.addAction(photos)
        alert.addAction(videos)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    

     // End SENDING BUTTON FUNCTIONS ---------
    
    // PICKER VIEW FUNCTIONS --------
    
    private func chooseMedia(type: CFString){
        
        picker.mediaTypes = [type as String]
        
        //presen the user all available media elements he chose
        present(picker, animated: true, completion: nil)
    }
    
    //after piciking an image, this funciton is called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //this will return an image in data format
            let data = UIImageJPEGRepresentation(pic, 0.01) //the smaller the compression nr, the worse the pic quality
            
            MessagesHandler.Instance.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName)
            
            
            /*//convert the image into a JSQMediaItem
            let img = JSQPhotoMediaItem(image: pic)
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img))
            */
            
        } else if let vidURL = info[UIImagePickerControllerMediaURL] as? URL {
            
            MessagesHandler.Instance.sendMedia(image: nil, video: vidURL, senderID: senderId, senderName: senderDisplayName)
            
            /*let video = JSQVideoMediaItem(fileURL: vidUrl, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video))
            */
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
    
    // END PICKER VIEW FUNCTIONS --------
    
    // DELEGATION FUNCTIONS ----------
    
    func messageReceived(senderID: String, senderName: String, text: String) {
        messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
        collectionView.reloadData()
    }
    
    func mediaReceived(senderID: String, senderName: String, url: String) {
        
        if let mediaURL = URL(string: url) {
            
            do {
                let data = try Data(contentsOf: mediaURL)
                
                if let _ = UIImage(data: data) { //if it works, we hava an image
                    
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, fnished) in
                        
                        //move to a background thread where we are containing the image (async = asynchronous)
                        DispatchQueue.main.async {
                            let photo = JSQPhotoMediaItem(image: image)
                            if senderID == self.senderId {
                                //make the message bubble point from the sender
                                photo?.appliesMediaViewMaskAsOutgoing = true
                            
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false
                            }
                            
                            self.messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo))
                            self.collectionView.reloadData()
                        }
                    
                    })
                    
                } else { //else it's a video
                    let video = JSQVideoMediaItem (fileURL: mediaURL, isReadyToPlay: true)
                    
                    if senderID == self.senderId {
                        //make the message bubble point from the sender
                        video?.appliesMediaViewMaskAsOutgoing = true
                        
                    } else {
                        video?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: video))
                    self.collectionView.reloadData()
                
                }
            }
            catch {
                // catch errors
                print("-------couldn't receive media message--------")
            }
            
        }
    }
    
    
    // END DELEGATION FUNCTIONS --------
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
} // Class
