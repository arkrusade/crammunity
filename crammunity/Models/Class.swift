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
	init(cramClass: FIRDataSnapshot)
	{
		className = FirebaseHelper.getStringFromDataSnapshot(Constants.ClassName, snapshot: cramClass)
		
	}
}
	