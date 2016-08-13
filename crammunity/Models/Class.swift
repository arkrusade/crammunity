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
	var className: String?
	var classUID: String!
	var ref: FIRDatabaseReference!
//	var messages: [ChatTextMessage]? = []
	var users: [User]? = [] //TODO: change to simpler user
	var chapters: [String]? = []
	init()
	{
		className = "Cool Class Name"
	}
	init(name: String, UID: String, ref: FIRDatabaseReference)
	{
		className = name
		classUID = UID
		self.ref = ref
	}
	init(snap: FIRDataSnapshot)
	{
		className = snap.value?.valueForKey(CramClassFKs.name) as? String

		
		classUID = snap.key
		ref = snap.ref
		
		
	}
	init(ref: FIRDatabaseReference)
	{
		self.ref = ref
		ref.observeSingleEventOfType(.Value, withBlock:  {(snapshot) -> Void in
			self.className = snapshot.value?.valueForKey(CramClassFKs.name) as? String
			self.classUID = snapshot.key
			
		})

	}
}
	//TODO: