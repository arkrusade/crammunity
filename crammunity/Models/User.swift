//
//  User.swift
//  crammunity
//
//  Created by Clara Hwang on 8/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

//TODO: finish inits

import Firebase
class User {
	let email: String?
	let username: String?
	let UID: String!
	let userRef: FIRDatabaseReference!
	let searchRef: FIRDatabaseReference?
	var userClasses: [Class]?
//	var friends: [User]!
	//TODO: change to simple user
	
	
	init(email: String?, username: String?, UID: String, ref: FIRDatabaseReference, searchRef: FIRDatabaseReference?, classes: [Class]?) {
		self.email = email
		self.username = username
		self.UID = UID
		self.userRef = ref
		self.searchRef = searchRef
		self.userClasses = classes
	}
	convenience init(snap: FIRDataSnapshot)//TODO: assert snap fits user type
	{
		let user = snap.value as! [String: String]
		self.init(email: user["email"]!, username: user["username"]!, UID: snap.key, ref: snap.ref, searchRef: snap.ref, classes: [])

	}
//	convenience init(ref: FIRDatabaseReference)
//	{
//		
//		ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
//			self.init(snap: snapshot)
//			})
//	}
}
