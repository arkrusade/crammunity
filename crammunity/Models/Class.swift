//
//  Class.swift
//  crammunity
//
//  Created by Clara Hwang on 6/30/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase

class Class {
	var className: String!
	var messages: [FIRDataSnapshot]! = []
	var users: [FIRDataSnapshot]! = []
	init()
	{
		className = "Cool Class Name"
	}
	//TODO: add messages and users
	//change init to create database values instead of take?
	init(cramClass: FIRDataSnapshot)
	{
		className = FirebaseHelper.getStringFromDatabaseKey(Constants.CramClass.Name, snapshot: cramClass)
		
	}
}
	