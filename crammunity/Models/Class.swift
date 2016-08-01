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
	init(cramClass: FIRDatabaseReference)
	{
//		cramClass.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
//			self.className = snapshot.value?.valueForKey("className") as! String
//		})
		FirebaseHelper.runCompletionOnDatabaseReference(cramClass, completion: {(snapshot) -> Void in
			self.className = snapshot.value?.valueForKey("className") as! String
		})
//		className = FirebaseHelper.getKeyFromDatabaseReference("className", ref: cramClass)
	}
}
	