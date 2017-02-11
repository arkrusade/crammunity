//
//  ClassViewController.swift
//  IPMQuickstart
//
//  Created by Kevin Whinnery on 12/9/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit

import Firebase

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@objc(ClassViewController)
class ClassViewController: UIViewController, UITableViewDelegate, UINavigationControllerDelegate {
	
	
	
	// Instance variables
	var _messageHandle: FIRDatabaseHandle!
	var _chapterHandle: FIRDatabaseHandle!
	var _currChapterHandle: FIRDatabaseHandle!
	var _currChapterRemoveHandle: FIRDatabaseHandle!
	var storageRef: FIRStorageReference!
	var chapterRef: FIRDatabaseReference!
//	var messagesRef: FIRDatabaseReference!
	
	var remoteConfig: FIRRemoteConfig!

	var classRef: FIRDatabaseReference!
	var classUID: String!
//	var messages: [FIRDataSnapshot]! = []
//TODO: change to chattextmessage
	
	var chapterUIDS: [String] = []
	var chapters: [Chapter] = [] {
		didSet {
			tableView.reloadData()
			
		}
	}
	
	var currentChapter: Chapter!
	var defaultChapter: Chapter {
		get {
			return Chapter(uid: "defaultUID", name: "defaultChapter", messages: [], ref: self.classRef.child("default"), cramClass: Class(name: "default", UID: "defaultUID", ref: classRef))
		}
	}
	var msglength: NSNumber = 0
	
	
	//@IBOutlet weak var banner: GADBannerView!

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var titleBar: UINavigationItem!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	let lengthOfBottomConstraint: CGFloat = 10
	@IBOutlet weak var textField: UITextField!
	
	//TODO: Change to loading inside of class view instead of sending to view
	
	// MARK: Class naming

	func configureNavigationBar() {
		
		let addFriendsBarButton = UIBarButtonItem(image: Constants.Images.add, style: .plain, target: self, action: #selector(goToCrammateAddition(_: )))
		//let settingsBarButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(goToClassSettings(_: )))
		//TODO: settings
		self.navigationItem.rightBarButtonItems = [/*settingsBarButton, */addFriendsBarButton]
		
	}
	
	func goToClassSettings(_ sender: AnyObject?)
	{
		print("go to class settings")
		performSegue(withIdentifier: Constants.Segues.CramChatToSettings, sender: self)
	}
	
	func goToCrammateAddition(_ sender: AnyObject?)
	{
		print("go to add crammates")
		performSegue(withIdentifier: Constants.Segues.CramChatToCrammateAddition, sender: self)
	}
	// MARK: UI controls
	
	@IBAction func onMoreButtonTap(_ sender: UIButton){
		var alertController: UIAlertController
		//TODO: improve this
		if let chap = currentChapter, chap.name != "defaultChapter" {
			alertController = UIAlertController(title: "Current Chapter: \(chap.name ?? "")", message: "What do you want to do?", preferredStyle: .actionSheet)
		}
		else{
			alertController = UIAlertController(title: "No Current Chapter", message: "What do you want to do?", preferredStyle: .actionSheet)

		}
		let addFileAction = UIAlertAction(title: "Add a Photo", style: .default, handler: {(action) -> Void in
			self.didTapAddPhoto(self)
		})
		let addChapterAction = UIAlertAction(title: "Add a Chapter", style: .default, handler: {(action) -> Void in
			self.onAddChapterButtonTap(self)
		})
		alertController.addAction(addFileAction)
		alertController.addAction(addChapterAction)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) -> Void in
			print("User clicked button called \(action.title) or tapped elsewhere")
		}))

		self.present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func onAddChapterButtonTap(_ sender: AnyObject)
	{
		let alert = UIAlertController(title: "Change chapter", message: "Enter the new chapter name", preferredStyle: .alert)
		
		alert.addTextField(configurationHandler: { (textField) -> Void in
			textField.placeholder = "(Chapter 1, Poetry, Organelles, etc.)"
		})
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
			let name = alert.textFields![0].text
			if name != nil && name != "" {
				let n = name!
				let chapter = FirebaseHelper.shared.createChapter(withName: n, UID: self.classUID)
				//TODO: add database interaction
				let confirm = UIAlertController(title: "Changed Chapter to \(chapter.name!)", message: "", preferredStyle: .alert)
				confirm.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(confirm, animated: true, completion: nil)
			}
			
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		
		self.present(alert, animated: true, completion: nil)
		
	}
	
	@IBAction func unwindToClassViewController(_ segue: UIStoryboardSegue) {
		print("unwinding to class view")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureNavigationBar()
		
		configureDatabase()
		configureStorage()
		configureRemoteConfig()
		fetchConfig()
//		loadAd()
//		logViewLoaded()

		// Listen for keyboard events and animate text field as necessary
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardWillShow(_:)),
		                                                 name:NSNotification.Name.UIKeyboardWillShow,
		                                                 object: nil);
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardDidShow(_:)),
		                                                 name:NSNotification.Name.UIKeyboardDidShow,
		                                                 object: nil);
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardWillHide(_:)),
		                                                 name:NSNotification.Name.UIKeyboardWillHide,
		                                                 object: nil);
		
		// Set up UI controls
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 66.0
		self.tableView.separatorStyle = .none
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Constants.Segues.CramChatToSettings
		{
			let vc = segue.destination as! ClassSettingsViewController
			vc.navigationItem.leftItemsSupplementBackButton = true
		}
		else if segue.identifier! == Constants.Segues.CramChatToCrammateAddition
		{
			let vc = segue.destination as! CrammateAdditionViewController
			vc.cramClass = self.classRef
			vc.navigationItem.leftItemsSupplementBackButton = true
			vc.title = "Add Crammates"
		}

	}
	
		

	// MARK: Firebase stuff
		
	@IBAction func didPressFreshConfig(_ sender: AnyObject) {
		fetchConfig()
	}
	
	@IBAction func didSendMessage(_ sender: UIButton) {
		textFieldShouldReturn(textField)
	}
	
//	@IBAction func didPressCrash(_ sender: AnyObject) {
//		FIRCrashMessage("Cause Crash button clicked")
//		fatalError("asdf")
//	}
//	
//	func logViewLoaded() {
//		FIRCrashMessage("View loaded")
//	}
	//TODO: add ad view
//	func loadAd() {
//		self.banner.adUnitID = kBannerAdUnitID
//		self.banner.rootViewController = self
//		self.banner.loadRequest(GADRequest())
//	}
	func sendMessage(_ data: [String: String]) {
		
		var mdata = data
		mdata[MessageFKs.username] = AppState.sharedInstance.displayName
		if let photoURL = AppState.sharedInstance.photoURL {
			mdata[MessageFKs.photoURL] = photoURL.absoluteString
		}
		let message = ChatTextMessage(dict: mdata)
		//TODO: make profile load with user
		//add user to message
		
		if let chap = currentChapter {
			mdata["chapter"] = chap.UID
			FirebaseHelper.shared.addTextMessageToChapter(chap, message: message)
		}
		
		//TODO: fix chapter constants
		// Push data to Firebase Database
		if let currentChapter = currentChapter {
			message.messageRef = currentChapter.ref.childByAutoId()
			message.chapterUID = currentChapter.ref.key
			FirebaseHelper.shared.addTextMessageToChapter(currentChapter, message: message)
		}
		

		//Send to Analytics
		MeasurementHelper.sendMessageEvent()
	}
	
	deinit {
//		self.messagesRef.removeAllObservers()
		self.chapterRef.removeAllObservers()
		self.classRef.removeAllObservers()
	}
	
	// UITableViewDataSource protocol methods
		
	
}
