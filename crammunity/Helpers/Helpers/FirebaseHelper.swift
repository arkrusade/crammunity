//
//  FirebaseHelper.shared.swift
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

typealias FIRObserverCallback = (FIRDataSnapshot) -> Void
class FirebaseHelper
{
     static let shared = FirebaseHelper()
	 let lastU = UnicodeScalar(1114111)
    
    //MARK: Firebase References
	 let usersRef = Constants.Firebase.UserArray
	 let userSearchRef = Constants.Firebase.UserSearchArray
	 let errorRef = Constants.Firebase.ErrorsArray
	 let reportsRef = Constants.Firebase.ReportsArray
	 let messageReportsRef = Constants.Firebase.MessageReports
	 var friendsRef = Constants.Firebase.FriendsArray
	 let classesRef = Constants.Firebase.CramClassArray

	
	
	//MARK: Errors
	
	func postErrorReference(_ title: String, desc: String, ref: FIRDatabaseReference, time: Date)
	{
		let error = errorRef.childByAutoId()
		error.child(ErrorFirebaseKeys.title
			).setValue(title)
		error.child(ErrorFirebaseKeys.desc).setValue(desc)
		error.child(ErrorFirebaseKeys.ref).setValue(ref.url)
		error.child(ErrorFirebaseKeys.time).setValue(time.description)
	}
	enum ReportError: String{
		case Message = "messageReports"
	}
	func postReport(_ type: ReportError, title: String, reportingUserUID: String, desc: String, ref: FIRDatabaseReference)
	{
		let report = reportsRef.child(type.rawValue).childByAutoId()
		let reportData = [ ReportFirebaseKeys.title : title, ReportFirebaseKeys.userUID : reportingUserUID, ReportFirebaseKeys.desc : desc, ReportFirebaseKeys.ref : ref.url]
		report.setValue(reportData)
//		ReportFirebaseKeys.title).setValue(time.description)
		ref.child("isReported").setValue("true")

	}

	
	//MARK: Queries
    func emptyQuery() -> FIRDatabaseQuery
    {
        return FIRDatabaseQuery()
    }

	func usersQuery() -> FIRDatabaseQuery
	{
		return usersRef.queryOrdered(byChild: "username").queryLimited(toFirst: 20)
	}
	func usersQuery(limitedTo: UInt) -> FIRDatabaseQuery
	{
        if limitedTo == 0
        {
            return FIRDatabaseQuery()
        }
		return usersRef.queryOrdered(byChild: "username").queryLimited(toFirst: limitedTo)
	}
	func usersQuery(byUsername: String) -> FIRDatabaseQuery
	{
		return usersRef.queryOrdered(byChild: "username").queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)").queryLimited(toFirst: 20)
	}
	func usersQuery(limitedTo: UInt, byUsername: String) -> FIRDatabaseQuery
	{
        if limitedTo == 0
        {
            return FIRDatabaseQuery()
        }

		return usersRef.queryOrdered(byChild: "username").queryLimited(toFirst: limitedTo).queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)")
	}
	
	
	func friendsQuery() -> FIRDatabaseQuery
	{
		let q = friendsRef.queryOrdered(byChild: "username").queryLimited(toFirst: 20)
		return q
	}
	func friendsQuery(limitedTo num: UInt) -> FIRDatabaseQuery
	{
        if num == 0
        {
            return FIRDatabaseQuery()
        }
		return friendsRef.queryOrdered(byChild: "username").queryLimited(toFirst: num)
	}
	func friendsQuery(byUsername: String) -> FIRDatabaseQuery
	{
		return friendsRef.queryOrdered(byChild: "username").queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)")
	}
	func friendsQuery(limitedTo num: UInt, byUsername: String) -> FIRDatabaseQuery
	{
        if num == 0
        {
            return FIRDatabaseQuery()
        }

		return friendsRef.queryOrdered(byChild: "username").queryLimited(toFirst: num).queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)")
	}
	
	
	func crammatesQuery(_ classRef: FIRDatabaseReference) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrdered(byChild: "username").queryLimited(toFirst: 20)
	}
	func crammatesQuery(_ classRef: FIRDatabaseReference, limitedTo: UInt) -> FIRDatabaseQuery
	{
        if limitedTo == 0
        {
            return FIRDatabaseQuery()
        }
		return classRef.child("members").queryOrdered(byChild: "username").queryLimited(toFirst: limitedTo)
	}
	func crammatesQuery(_ classRef: FIRDatabaseReference, byUsername: String) -> FIRDatabaseQuery
	{
		return classRef.child("members").queryOrdered(byChild: "username").queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)")
	}
	func crammatesQuery(_ classRef: FIRDatabaseReference, limitedTo: UInt, byUsername: String) -> FIRDatabaseQuery
	{
        if limitedTo == 0
        {
            return FIRDatabaseQuery()
        }
		return classRef.child("members").queryOrdered(byChild: "username").queryLimited(toFirst: limitedTo).queryStarting(atValue: byUsername).queryEnding(atValue: "\(byUsername)\(lastU)")
	}

        
	//MARK: User structure
	
	func setCurrentUserPhotoURL(_ url: String)
	{
		let changeRequest = Constants.Firebase.currentUser.profileChangeRequest()
		changeRequest.photoURL = URL(string: url)
		//TODO: add background thread to download image for profile view
		changeRequest.commitChanges(){ (error) in
			if let error = error {
				ErrorHandling.defaultError(error)
				return
			}
			else {
				//TODO: add userFKS
				AppState.sharedInstance.userRef?.child("photoURL").setValue(url)
			}
			
		}
	}
	
	func createUser(_ email: String, pw: String, username: String, callback: @escaping (FIRUser?) -> Void) //-> FIRUser?
	{
		FIRAuth.auth()?.createUser(withEmail: email, password: pw, completion: { user, error in
			
			if error != nil {
                ErrorHandling.defaultError("Database Error: User Creation", desc: error!.localizedDescription, sender: nil)
				callback(nil)
			} else {
				let uid = user?.uid
				UserDefaults.standard.setValue(uid, forKey: "uid")
				AppState.sharedInstance.userRef = Constants.Firebase.UserArray.child(uid!)
				Constants.Firebase.UserSearchArray.child(uid!).setValue(["username": username])
				Constants.Firebase.UserArray.child(uid!).setValue(["username": username])
				AppState.sharedInstance.userRef = Constants.Firebase.UserArray.child(uid!)

				print ("Created user with uid: \(user!.uid) and username: \(username)")
				
				//set default profile pic and username
				let changeRequest = user!.profileChangeRequest()
				changeRequest.displayName = username
				changeRequest.photoURL =
					URL(string: "gs://crammunity.appspot.com/defaults/profilePicture/profile-256.png")
				changeRequest.commitChanges(){ (error) in
					if let error = error {
						ErrorHandling.defaultError(error)
						callback(nil)
						return
					}
					else {
						//TODO: add userFKS
						AppState.sharedInstance.userRef?.child("photoURL").setValue("gs://crammunity.appspot.com/defaults/profilePicture/profile-256.png")
						callback(user)
					}
					
				}
				
			}
			
		})
	}
	//MARK: Chapter structure
	func addTextMessageToChapter(_ chapter: Chapter, message: ChatTextMessage)
	{
		var mdata = [MessageFKs.username: message.username!]
		mdata[MessageFKs.chapter] = message.chapterUID ?? ""
		if let imageURL = message.imageURL
		{
			mdata[MessageFKs.imageURL] = imageURL
		}
		if let text = message.text
		{
			mdata[MessageFKs.text] = text
		}
		if message.isReported
		{
			mdata[MessageFKs.isReported] = "true"
		}
		chapter.ref.child(ChapterFKs.MessagesArray).child(message.messageRef.key).setValue(mdata)
//			.child("messageType").setValue(ChapterFKs.TextMessage)
		//TODO: change to time
		//TODO: fix this
		//add user uid
	}
    
	func createChapter(withName name: String, UID cramClassUID: String) -> Chapter{
		//TODO: account for chronological order
		//could remove currchapt and instead keep track of last chapter
		let classRef = classesRef.child(cramClassUID)
		let chapterRef = classRef.child("chapters").childByAutoId()
		chapterRef.setValue(["chapterName":name])
		let cramClass = Class(ref: classRef)
		let chap = Chapter(uid: chapterRef.key, name: name, messages: [], ref: chapterRef, cramClass: cramClass)
		setCurrentChapterFor(class: classRef, withChapter: chap)
		return chap
	}
    
    func setCurrentChapterFor(class cramClass: FIRDatabaseReference, withChapter: Chapter)
    {
        cramClass.child("currentChapter").removeValue()
        let mdata = [ChapterFKs.name : withChapter.name!]
        cramClass.child("currentChapter").child(withChapter.UID).setValue(mdata)
    }
    //MARK: Friend structure
	func addFriend(_ friendSnap: FIRDataSnapshot)
	{
		let friendUsername = (friendSnap.value! as AnyObject).value(forKey: "username") as! String
		let friendData = ["username": friendUsername]
		let userData = ["username": AppState.sharedInstance.displayName!]
		usersRef.child((Constants.Firebase.currentUser.uid)).child("friends").child(friendSnap.key).setValue(friendData)
		usersRef.child(friendSnap.key).child("friends").child((Constants.Firebase.currentUser.uid)).setValue(userData)
	}
	
	func removeFriend(_ friendSnap: FIRDataSnapshot)
	{
		usersRef.child((Constants.Firebase.currentUser.uid)).child("friends").child(friendSnap.key).removeValue()
		usersRef.child(friendSnap.key).child("friends").child(Constants.Firebase.currentUser.uid).removeValue()
	}
	
	//MARK: Class structure
	func addUserToClass(_ user: FIRDataSnapshot, cramClass: FIRDatabaseReference)
	{
		var username = ""
		username = (user.value! as AnyObject).value(forKey: "username") as! String
		cramClass.child("members").child(user.key).child("username").setValue(username)
		var className: String = ""
		
		cramClass.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
			className = (snapshot.value! as AnyObject).value(forKey: "className") as! String
			self.usersRef.child(user.key).child("classes").child(cramClass.key).child("className").setValue(className)
		})

	}
	
	func addUserToClass(_ user: FIRDataSnapshot, cramClassUID: String)
	{
		let classRef = Constants.Firebase.CramClassArray.child(cramClassUID)
		addUserToClass(user, cramClass: classRef)
	}
	
	
	func removeUserFromClass(_ user: FIRDataSnapshot, cramClass: FIRDatabaseReference)
	{
		cramClass.child("members").child(user.key).child("username").removeValue()
		
		usersRef.child(user.key).child("classes").child(cramClass.key).removeValue()
	}
	func removeUserFromClass(_ userUID: String, cramClass: FIRDatabaseReference)
	{
		cramClass.child("members").child(userUID).child("username").removeValue()
		
		usersRef.child(userUID).child("classes").child(cramClass.key).removeValue()
	}
	
	
	func removeCurrentUserFromClass(_ cramClass: FIRDataSnapshot) {
		removeUserFromClass((FIRAuth.auth()?.currentUser?.uid)!, cramClass: cramClass.ref)
	}
	
	func createClass(_ name: String) -> FIRDatabaseReference
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
