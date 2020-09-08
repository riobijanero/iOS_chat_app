//
//  ContactsVC.swift
//  ChatApp
//
//  Created by Bijan on 08.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController, UITabBarDelegate, UITableViewDataSource, FetchData {

    
    @IBOutlet weak var myTable: UITableView!
    
    private let CELL_ID = "Cell"
    private let CHATE_SEGUE = "ChatSegue"
    
    private var contacts = [Contact]()  //array of tyoe Contacs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBProvider.Instance.delegate = self
        DBProvider.Instance.getContacts()
    }

    //functions being execued because we are confirming to the FetchData protocol
    func dataReceived(contacts: [Contact]) {
        
        //get all contacts available
        self.contacts = contacts
        
        //get the name of the current user
        for contact in contacts {
            if contact.id == AuthProvider.Instance.userID() {
                AuthProvider.Instance.userName = contact.name
            }
        }
        
        myTable.reloadData()
        print("----DATA RECEIVED-----")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //nr of rows that the tableView shoould show depends = nr of contacts the user has
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        
        //cell.textLabel?.text = "this really works"
        cell.textLabel?.text = contacts[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: CHATE_SEGUE, sender: nil)
    }
    
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            //if it returns true, then we have logged out
            dismiss(animated: true, completion: nil)
        }
        
        
    
    }
    
   

}
