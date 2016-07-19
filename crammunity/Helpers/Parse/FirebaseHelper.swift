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
	
	static let ref = FIRDatabase.database().reference()
	
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

	static func createClass(name: String) -> FIRDatabaseReference
	{
		let nameData = [Constants.CramClass.Name: name]
		let classRef = self.ref.child("classes").childByAutoId()
		classRef.setValue(nameData)
		classRef.child("members").child("\((FIRAuth.auth()?.currentUser?.uid)!)").child("username").setValue(AppState.sharedInstance.displayName!)
		print("created class \(name)")
		return classRef
	}
	
//	static func loadClasses() -> [FIRDataSnapshot]
//	{
//			// 1
//		let classesQuery = ref.child("classes").queryLimitedToLast(25)
//		var classes: [FIRDataSnapshot] = []
//		classesQuery.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
//			if !classes.contains(snapshot)
//			{
//				classes.append(snapshot)
//			}
//			
//		}
//		return classes
//		
//	}
//	static func loading() -> [FIRDataSnapshot]
//	{
//		var messages: [FIRDataSnapshot] = []
//		let _refHandle = ref.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
//			messages.append(snapshot)
//			
//		})
//		return messages
//
//	}
//		vc.ref.child("users").child(User.newID()).setValue(["username": username])
//		FIRAuth.auth()?.createUserWithEmail(email, password: pw) { (user, error) in
//			if error != nil {
//				print("error creating user")
//			} else {
//				let uid = result["uid"] as! String
//				NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
//				//pass the parameters to another function to auth the user
//				self.authUserWithAuthData( email, password: pw )
//			}		}
//	}
}