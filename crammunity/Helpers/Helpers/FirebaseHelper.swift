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
	
	//MARK: Queries
	//TODO: add completion with error
	static func getStringFromDataSnapshot(key: String, snapshot: FIRDataSnapshot) -> String
	{
		let snap = snapshot.value!
		let name = snap[key]
		return name.description
//		return ""
	}
	
	static func allUsers() -> FIRDatabaseQuery
	{
		return Constants.Firebase.UserArray.queryOrderedByChild("username")
	}
	static func allUsers(limitedTo: UInt) -> FIRDatabaseQuery
	{
		return Constants.Firebase.UserArray.queryOrderedByChild("username").queryLimitedToFirst(limitedTo)
	}
	static func allUsers(byUsername: String) -> FIRDatabaseQuery
	{
		return Constants.Firebase.UserArray.queryOrderedByChild("username")
	}
	
	//MARK: Structure organizers
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
	
	static func addFriend(friendSnap: FIRDataSnapshot)
	{
		let friendUsername = friendSnap.value!.valueForKey("username") as! String
		let friendData = ["username": friendUsername]
		let userData = ["username": AppState.sharedInstance.displayName!]
		Constants.Firebase.UserArray.child(Constants.currentUser.uid).child("friends").child(friendSnap.key).setValue(friendData)
		Constants.Firebase.UserArray.child(friendSnap.key).child("friends").child(Constants.currentUser.uid).setValue(userData)
	}
	
	static func removeFriend(friendSnap: FIRDataSnapshot)
	{
		Constants.Firebase.UserArray.child(Constants.currentUser.uid).child("friends").child(friendSnap.key).removeValue()
		Constants.Firebase.UserArray.child(friendSnap.key).child("friends").child(Constants.currentUser.uid).removeValue()
	}
	
	
	//TODO: fix user add to class
//	static func addUserToClass(user: FIRUser, cramClass: FIRDatabaseReference)
//	{
//		cramClass.child("members").child(user.uid).child("username").setValue(AppState.sharedInstance.displayName!)
//		Constants.Firebase.UserArray.child(user.uid).child("classes").child(cramClass.key).setValue(cramClass.child(Constants.ClassName))
//	}
//	static func addUserToClass(user: FIRUser, cramClassUID: String)
//	{
//		let classRef = Constants.Firebase.CramClassArray.child(cramClassUID)
//		addUserToClass(user, cramClass: classRef)
//	}
	static func createClass(name: String) -> FIRDatabaseReference
	{
		let classData = [Constants.ClassName: name]
		let classRef = Constants.Firebase.CramClassArray.childByAutoId()
		classRef.setValue(classData)
		
//		addUserToClass((Constants.currentUser)!, cramClass: classRef)
		classRef.child("members").child((Constants.currentUser).uid).child("username").setValue(AppState.sharedInstance.displayName!)
		Constants.Firebase.UserArray.child((Constants.currentUser).uid).child("classes").child(classRef.key).child(Constants.ClassName).setValue(name)
		
		print("created class \(name)")
		return classRef
	}
}