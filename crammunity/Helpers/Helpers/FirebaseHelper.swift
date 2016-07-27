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
	static let lastU = UnicodeScalar(1114111)
	static let usersRef = Constants.Firebase.UserArray
	static let friendsRef = usersRef.child((FIRAuth.auth()?.currentUser!.uid)!).child("friends")


	//TODO: add completion with error
	static func getStringFromDataSnapshot(key: String, snapshot: FIRDataSnapshot) -> String
	{
		let snap = snapshot.value!
		let name = snap[key]
		return name.description
//		return ""
	}
	//MARK: Queries

	static func usersQuery() -> FIRDatabaseQuery
	{
		return usersRef.queryOrderedByChild("username").queryLimitedToFirst(20)
	}
	static func usersQuery(limitedTo: UInt) -> FIRDatabaseQuery
	{
		return usersRef.queryOrderedByChild("username").queryLimitedToFirst(limitedTo)
	}
	static func usersQuery(byUsername: String) -> FIRDatabaseQuery
	{
		return usersRef.queryOrderedByChild("username").queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)").queryLimitedToFirst(20)
	}
	static func usersQuery(limitedTo: UInt, byUsername: String) -> FIRDatabaseQuery
	{
		return usersRef.queryOrderedByChild("username").queryLimitedToFirst(limitedTo).queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)")
	}
	
	
	static func friendsQuery() -> FIRDatabaseQuery
	{
		return friendsRef.queryOrderedByChild("username").queryLimitedToFirst(20)
	}
	static func friendsQuery(limitedTo: UInt) -> FIRDatabaseQuery
	{
		return friendsRef.queryOrderedByChild("username").queryLimitedToFirst(limitedTo)
	}
	static func friendsQuery(byUsername: String) -> FIRDatabaseQuery
	{
		return friendsRef.queryOrderedByChild("username").queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)")
	}
	static func friendsQuery(limitedTo: UInt, byUsername: String) -> FIRDatabaseQuery
	{
		return friendsRef.queryOrderedByChild("username").queryLimitedToFirst(limitedTo).queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)")
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
		usersRef.child((FIRAuth.auth()?.currentUser!.uid)!).child("friends").child(friendSnap.key).setValue(friendData)
		usersRef.child(friendSnap.key).child("friends").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(userData)
	}
	
	static func removeFriend(friendSnap: FIRDataSnapshot)
	{
		usersRef.child((FIRAuth.auth()?.currentUser!.uid)!).child("friends").child(friendSnap.key).removeValue()
		usersRef.child(friendSnap.key).child("friends").child((FIRAuth.auth()?.currentUser!.uid)!).removeValue()
	}
	
	
	//TODO: fix user add to class
//	static func addUserToClass(user: FIRUser, cramClass: FIRDatabaseReference)
//	{
//		cramClass.child("members").child(user.uid).child("username").setValue(AppState.sharedInstance.displayName!)
//		usersRef.child(user.uid).child("classes").child(cramClass.key).setValue(cramClass.child(Constants.ClassName))
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
		
//		addUserToClass((FIRAuth.auth()?.currentUser!)!, cramClass: classRef)
		classRef.child("members").child((FIRAuth.auth()?.currentUser!)!.uid).child("username").setValue(AppState.sharedInstance.displayName!)
		usersRef.child((FIRAuth.auth()?.currentUser!)!.uid).child("classes").child(classRef.key).child(Constants.ClassName).setValue(name)
		
		print("created class \(name)")
		return classRef
	}
}