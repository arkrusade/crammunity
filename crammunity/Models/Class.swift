//
//  Class.swift
//  crammunity
//
//  Created by Clara Hwang on 6/30/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase
//TODO: simpler user should refer to user
class Class {
	var className: String!
	var messages: [ChatMessage]! = []
	var users: [User]! = [] //TODO: change to simpler user
	var chapters: [String]? = []
	init()
	{
		className = "Cool Class Name"
	}
	init(cramClass: FIRDataSnapshot)
	{
		className = FirebaseHelper.getStringFromDataSnapshot(CramClassFKs.name, snapshot: cramClass)
		
	}
	init(cramClass: FIRDatabaseReference)
	{
		cramClass.observeSingleEventOfType(.Value, withBlock:  {(snapshot) -> Void in
			self.className = snapshot.value?.valueForKey(CramClassFKs.name) as! String
			
		})

	}
}
	//TODO: