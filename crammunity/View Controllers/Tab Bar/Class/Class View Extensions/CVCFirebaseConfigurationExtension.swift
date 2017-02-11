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
//		messagesRef = Constants.Firebase.CramClassArray.child(classRef.key).child(CramClassFKs.MessagesArray)
		chapterRef = Constants.Firebase.CramClassArray.child(classRef.key).child(CramClassFKs.ChapterArray)
		self.currentChapter = defaultChapter
		_chapterHandle = chapterRef.observe(.childAdded, with: { snapshot in
			if snapshot.exists() {
				self.chapters.append(Chapter(snapshot: snapshot))
				self.chapterUIDS.append(snapshot.key)
			} else {
                ErrorHandling.defaultError(desc: "error in chapter loading", sender: self)
				
			}
		})
		//TODO: edit classFKS
		//CramClassFKs.currentChapter
        
		_currChapterHandle = classRef.child(CramClassFKs.currentChapter).observe(.childAdded, with: { snapshot in
			if snapshot.exists() {
				let chap = Chapter.init(snapshot: snapshot)
				chap.ref = self.classRef.child(CramClassFKs.ChapterArray).child(snapshot.key)
				self.currentChapter = chap
			}
			else {
				self.currentChapter = self.defaultChapter
			}
		})
		_currChapterRemoveHandle = classRef.child(CramClassFKs.currentChapter).observe(.childRemoved, with: { snapshot in
			self.currentChapter = self.defaultChapter
		})
		
		//find new messages
		_messageHandle = chapterRef.observe(.childChanged, with: { snapshot in
			if snapshot.exists() {
				if self.chapterUIDS.contains(snapshot.key)
				{
					self.chapters[self.chapterUIDS.index(of: snapshot.key)!] = Chapter(snapshot: snapshot)
					//TODO: make more efficient by only changing messages
					
				}
				
			} else {
                ErrorHandling.defaultError(desc: "error in message loading", sender: self)
				
			}
		})
	}
	//TODO: add storage in specific class
	func configureStorage() {
		storageRef = FIRStorage.storage().reference(forURL: "gs://crammunity.appspot.com/")
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
		remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) in
			if (status == .success) {
				print("Config fetched!")
				self.remoteConfig.activateFetched()
				let friendlyMsgLength = self.remoteConfig["friendly_msg_length"]
				if (friendlyMsgLength.source != .static) {
					self.msglength = friendlyMsgLength.numberValue!
					print("Friendly msg length config: \(self.msglength)")
				}
			} else {
				ErrorHandling.defaultError("Config not fetched", desc: "\(error?.localizedDescription)", sender: self)
			}
		}
	}
}
