//
//  CVCFirebaseConfigurationExtension.swift
//  crammunity
//
//  Created by Clara Hwang on 8/5/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Firebase
extension ClassViewController{
	
	
	func configureDatabase() {
		messagesRef = Constants.Firebase.CramClassArray.child(classRef.key).child(CramClassFKs.MessagesArray)
		chapterRef = Constants.Firebase.CramClassArray.child(classRef.key).child(CramClassFKs.ChapterArray)
		
		_chapterHandle = chapterRef.observeEventType(.ChildAdded, withBlock: { snapshot in
			if snapshot.exists() {
				self.chapters.append(Chapter(snapshot: snapshot))
//				snapshot.value?.valueForKey(ChapterFKs.name))! as! String
				
			} else {
				ErrorHandling.defaultErrorHandler("error in chapter loading")
				
			}
		})
		//TODO: edit classFKS
		_currChapterHandle = classRef.child("currentChapter").observeEventType(.Value, withBlock: { snapshot in
			if snapshot.exists() {
				self.currentChapter = snapshot.value as? String
			}
//			else {
//				ErrorHandling.defaultErrorHandler("error in chapter loading")
//				
//			}
		})
		//find new messages
		_refHandle = messagesRef.observeEventType(.ChildAdded, withBlock: { snapshot in
			if snapshot.exists() {
				self.messages.append(snapshot)
				self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
				
			} else {
				ErrorHandling.defaultErrorHandler("error in message loading")
				
			}
		})
	}
	//TODO: add storage in specific class
	func configureStorage() {
		storageRef = FIRStorage.storage().referenceForURL("gs://crammunity.appspot.com/")
	}
	
	func configureRemoteConfig() {
		remoteConfig = FIRRemoteConfig.remoteConfig()
		// Create Remote Config Setting to enable developer mode.
		// Fetching configs from the server is normally limited to 5 requests per hour.
		// Enabling developer mode allows many more requests to be made per hoøur, so developers
		// can test different config values during development.
		//TODO: change config
		let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
		remoteConfig.configSettings = remoteConfigSettings!
	}
	
	func fetchConfig() {
		var expirationDuration: Double = 3600
		// If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
		// the server.
		if (self.remoteConfig.configSettings.isDeveloperModeEnabled) {
			expirationDuration = 0
		}
		
		// cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
		// fetched and cached config would be considered expired because it would have been fetched
		// more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
		// throttling is in progress. The default expiration duration is 43200 (12 hours).
		remoteConfig.fetchWithExpirationDuration(expirationDuration) { (status, error) in
			if (status == .Success) {
				print("Config fetched!")
				self.remoteConfig.activateFetched()
				let friendlyMsgLength = self.remoteConfig["friendly_msg_length"]
				if (friendlyMsgLength.source != .Static) {
					self.msglength = friendlyMsgLength.numberValue!
					print("Friendly msg length config: \(self.msglength)")
				}
			} else {
				ErrorHandling.defaultErrorHandler("Config not fetched", desc: "\(error?.description)")
			}
		}
	}
}
