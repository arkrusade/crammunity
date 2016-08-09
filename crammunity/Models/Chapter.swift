//
//  Chapter.swift
//  crammunity
//
//  Created by Clara Hwang on 8/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

import Firebase
class Chapter {
	var name: String!
	var messages: [ChatMessage]! = []
	var ref: FIRDatabaseReference
	init()
	{
		name = "Cool Chapter Name"
		ref = Constants.Firebase.rootRef
	}
//	init(cramClass: FIRDataSnapshot)
//	{
//		name = FirebaseHelper.getStringFromDataSnapshot(CramClassFKs.name, snapshot: cramClass)
//		
//	}
	convenience init(chapterRef: FIRDatabaseReference)
	{
		self.init()
		self.ref = chapterRef
		chapterRef.observeSingleEventOfType(.Value, withBlock:  {(snapshot) -> Void in
			self.name = snapshot.value?.valueForKey(ChapterFKs.name) as! String
			let ms = snapshot.value?.valueForKey(ChapterFKs.MessagesArray) as! [String: String]
			
			
		})
		
	}
}
//TODO:
