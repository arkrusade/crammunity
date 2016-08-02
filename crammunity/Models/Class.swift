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
		className = FirebaseHelper.getStringFromDataSnapshot(CramClassFKs.name, snapshot: cramClass)
		
	}
	init(cramClass: FIRDatabaseReference)
	{
		FirebaseHelper.runCompletionOnDatabaseReference(cramClass, completion: {(snapshot) -> Void in
			self.className = snapshot.value?.valueForKey(CramClassFKs.name) as! String
		})

	}
}
	