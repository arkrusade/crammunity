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

typealias FIRObserverCallback = FIRDataSnapshot -> Void
class FirebaseHelper
{
	static let lastU = UnicodeScalar(1114111)
	static let usersRef = Constants.Firebase.UserArray
	static let userSearchRef = Constants.Firebase.UserSearchArray
	static let errorRef = Constants.Firebase.ErrorsArray
	static let reportsRef = Constants.Firebase.ReportsArray
	static let messageReportsRef = Constants.Firebase.MessageReports
	static var friendsRef = Constants.Firebase.FriendsArray
	static let classesRef = Constants.Firebase.CramClassArray
	//TODO: add completion with error
	static func getStringFromDataSnapshot(key: String, snapshot: FIRDataSnapshot) -> String
	{
		let snap = snapshot.value!
		let name = snap[key]
		return name.description
	}
	
//	static func runCompletionOnDatabaseReference(ref: FIRDatabaseReference, completion: FIRObserverCallback) -> Void
//	{
//		ref.observeSingleEventOfType(.Value, withBlock: completion)
//	}
	
	static func postErrorReference(title: String, desc: String, ref: FIRDatabaseReference, time: NSDate)
	{
		let error = errorRef.childByAutoId()
		error.child(ErrorFirebaseKeys.title
			).setValue(title)
		error.child(ErrorFirebaseKeys.desc).setValue(desc)
		error.child(ErrorFirebaseKeys.ref).setValue(ref.URL)
		error.child(ErrorFirebaseKeys.time).setValue(time.description)
	}
	enum ReportError: String{
		case Message = "messageReports"
	}
	static func postReport(type: ReportError, title: String, reportingUserUID: String, desc: String, ref: FIRDatabaseReference)
	{
		let report = reportsRef.child(type.rawValue).childByAutoId()
		let reportData = [ ReportFirebaseKeys.title : title, ReportFirebaseKeys.userUID : reportingUserUID, ReportFirebaseKeys.desc : desc, ReportFirebaseKeys.ref : ref.URL]
		report.setValue(reportData)
//		ReportFirebaseKeys.title).setValue(time.description)
		ref.child("isReported").setValue("true")

	}
//	static func getErrorReferenceInTableViewCell(ref: FIRDatabaseReference) -> UITableViewCell
//	{
//		var text: String = ""
//		let completion: FIRObserverCallback = {(snapshot) -> Void in
//			var err: ErrorRef
//			let dict = snapshot.value
//			err.title = dict?.valueForKey("title") as! String
//			err.desc = dict?.valueForKey("desc") as! String
//			err.ref = snapshot.ref
//			text = err.title + ": " + err.desc
//		}
//		runCompletionOnDatabaseReference(ref, completion: completion)
//		let cell =
//		return err
//	}
	
	//MARK: Queries

	static func usersQuery() -> FIRDatabaseQuery
	{
		return usersRef.queryOrderedByChild("username").queryLimitedToFirst(0)
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
		let q = friendsRef.queryOrderedByChild("username").queryLimitedToFirst(20)
		return q
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
	
	
	static func crammatesQuery(classRef: FIRDatabaseReference) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrderedByChild("username").queryLimitedToFirst(20)
	}
	static func crammatesQuery(classRef: FIRDatabaseReference, limitedTo: UInt) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrderedByChild("username").queryLimitedToFirst(limitedTo)
	}
	static func crammatesQuery(classRef: FIRDatabaseReference, byUsername: String) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrderedByChild("username").queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)")
	}
	static func crammatesQuery(classRef: FIRDatabaseReference, limitedTo: UInt, byUsername: String) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrderedByChild("username").queryLimitedToFirst(limitedTo).queryStartingAtValue(byUsername).queryEndingAtValue("\(byUsername)\(lastU)")
	}

	//MARK: Structure organizers
	static func createUser(email: String, pw: String)
	{
		FIRAuth.auth()?.createUserWithEmail(email, password: pw, completion: { result, error in
			
			if error != nil {
				ErrorHandling.defaultErrorHandler("error creating user")
			} else {
				let uid = result?.uid
				NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
			}
			
		})
	}
	static func setCurrentChapterFor(cramClass: FIRDatabaseReference, withChapter: Chapter)
	{
		cramClass.child("currentChapter").setValue(withChapter.name)
	}
	
	static func createChapter(name: String, cramClassUID: String) -> Chapter{
		//TODO: account for chronological order
		//could remove currchapt and instead keep track of last chapter
		let classRef = classesRef.child(cramClassUID)
		let chapterRef = classRef.child("chapters").childByAutoId()
		chapterRef.setValue(["chapterName":name])
		let cramClass = Class(ref: classRef)
		let chap = Chapter(uid: chapterRef.key, name: name, messages: [], ref: chapterRef, cramClass: cramClass)
		setCurrentChapterFor(classRef, withChapter: chap)
		return chap
	}
	static func addFriend(friendSnap: FIRDataSnapshot)
	{
		let friendUsername = friendSnap.value!.valueForKey("username") as! String
		let friendData = ["username": friendUsername]
		let userData = ["username": AppState.sharedInstance.displayName!]
		usersRef.child((Constants.Firebase.currentUser.uid)).child("friends").child(friendSnap.key).setValue(friendData)
		usersRef.child(friendSnap.key).child("friends").child((Constants.Firebase.currentUser.uid)).setValue(userData)
	}
	
	static func removeFriend(friendSnap: FIRDataSnapshot)
	{
		usersRef.child((Constants.Firebase.currentUser.uid)).child("friends").child(friendSnap.key).removeValue()
		usersRef.child(friendSnap.key).child("friends").child(Constants.Firebase.currentUser.uid).removeValue()
	}
	
	
	static func addUserToClass(user: FIRDataSnapshot, cramClass: FIRDatabaseReference)
	{
		var username = ""
		username = user.value!.valueForKey("username") as! String
		cramClass.child("members").child(user.key).child("username").setValue(username)
		var className: String = ""
		
		cramClass.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
			className = snapshot.value!.valueForKey("className") as! String
			usersRef.child(user.key).child("classes").child(cramClass.key).child("className").setValue(className)
		})

	}
	
	static func addUserToClass(user: FIRDataSnapshot, cramClassUID: String)
	{
		let classRef = Constants.Firebase.CramClassArray.child(cramClassUID)
		addUserToClass(user, cramClass: classRef)
	}
	
	
	static func removeUserFromClass(user: FIRDataSnapshot, cramClass: FIRDatabaseReference)
	{
		cramClass.child("members").child(user.key).child("username").removeValue()
		
		usersRef.child(user.key).child("classes").child(cramClass.key).removeValue()
	}
	static func removeUserFromClass(userUID: String, cramClass: FIRDatabaseReference)
	{
		cramClass.child("members").child(userUID).child("username").removeValue()
		
		usersRef.child(userUID).child("classes").child(cramClass.key).removeValue()
	}
	
	
	static func removeCurrentUserFromClass(cramClass: FIRDataSnapshot) {
		removeUserFromClass((FIRAuth.auth()?.currentUser?.uid)!, cramClass: cramClass.ref)
	}
	
	static func createClass(name: String) -> FIRDatabaseReference
	{
		let classData = [CramClassFKs.name: name]
		
		let classRef = Constants.Firebase.CramClassArray.childByAutoId()
		classRef.setValue(classData)
		
//		addUserToClass((Constants.Firebase.currentUser)!, cramClass: classRef)
		classRef.child("members").child((Constants.Firebase.currentUser).uid).child("username").setValue(AppState.sharedInstance.displayName!)
		usersRef.child((Constants.Firebase.currentUser).uid).child("classes").child(classRef.key).child(CramClassFKs.name).setValue(name)
		
		print("created class \(name)")
		return classRef
	}
	
	
}