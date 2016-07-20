//
//  FirebaseHelper.swift
//  crammunity
//
//  Created by Clara Hwang on 7/11/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

class FirebaseHelper
{
	//TODO: add structs
	
	
	//TODO: add completion with error
	static func getStringFromDatabaseKey(key: String, snapshot: FIRDataSnapshot) -> String
	{
		let snap = snapshot.value!
		let name = snap[key]
		return name.description
//		return ""
	}
	static func createUser(email: String, pw: String)
	{
		FIRAuth.auth()?.createUserWithEmail(email, password: pw, completion: { result, error in
			
			if error != nil {
				print("error creating user")
			} else {
				let uid = result?.uid
				NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
			}
			
		})
	}
	
	static func addUserToClass(user: FIRUser, cramClass: FIRDatabaseReference)
	{
		cramClass.child("members").child(user.uid).child("username").setValue(AppState.sharedInstance.displayName!)
		Constants.Firebase.UserArray.child(user.uid).child("classes").setValue(cramClass.key)
	}
	static func addUserToClass(user: FIRUser, cramClassUID: String)
	{
		let classRef = Constants.Firebase.CramClassArray.child(cramClassUID)
		addUserToClass(user, cramClass: classRef)
	}
	static func createClass(name: String) -> FIRDatabaseReference
	{
		let nameData = [Constants.CramClass.Name: name]
		let classRef = Constants.Firebase.CramClassArray.childByAutoId()
		classRef.setValue(nameData)
		
		
		addUserToClass((FIRAuth.auth()?.currentUser)!, cramClass: classRef)
		
		print("created class \(name)")
		return classRef
	}
}