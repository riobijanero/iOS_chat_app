//
//  Contact.swift
//  ChatApp
//
//  Created by Bijan on 10.08.17.
//  Copyright © 2017 Bijan. All rights reserved.
//

import Foundation

class Contact {
    
    private var
    _name = "",
    _id = ""
    
    init(id: String, name: String){
        _id = id
        _name = name
    }
    
    var name: String {
        get {
            return _name
        }
    }
    
    
    //alternativ way for a getter (doesn't work for a setter):
    //setters must also have getters, but getters-only are possible
    var id: String {
        return _id
    }
} //class
