//
//  ClassViewController.swift
//  IPMQuickstart
//
//  Created by Kevin Whinnery on 12/9/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit

import Firebase
import GoogleMobileAds

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@objc(ClassViewController)
class ClassViewController: UIViewController, UITableViewDelegate, UINavigationControllerDelegate {
	
	
	// Instance variables
	@IBOutlet weak var sendButton: UIButton!
	var messagesRef: FIRDatabaseReference!
	var messages: [FIRDataSnapshot]! = []
	var msglength: NSNumber = 0
	var _refHandle: FIRDatabaseHandle!
	
	var storageRef: FIRStorageReference!
	var remoteConfig: FIRRemoteConfig!
	
	@IBOutlet weak var banner: GADBannerView!

	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var titleBar: UINavigationItem!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	let lengthOfBottomConstraint: CGFloat = 10
	@IBOutlet weak var textField: UITextField!
	
	var cramChat: FIRDatabaseReference!
	//TODO: Change to loading inside of class view instead of sending to view
	
	// MARK: Class naming

	func configureNavigationBar() {
		
		let addFriendsBarButton = UIBarButtonItem(image: Constants.Images.add, style: .Plain, target: self, action: #selector(goToCrammateAddition(_: )))
		//let settingsBarButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(goToClassSettings(_: )))
		//TODO: settings
		self.navigationItem.rightBarButtonItems = [/*settingsBarButton, */addFriendsBarButton]
		
	}
	
	func goToClassSettings(sender: AnyObject?)
	{
		print("go to class settings")
		performSegueWithIdentifier(Constants.Segues.CramChatToSettings, sender: self)
	}
	
	func goToCrammateAddition(sender: AnyObject?)
	{
		print("go to add crammates")
		performSegueWithIdentifier(Constants.Segues.CramChatToCrammateAddition, sender: self)
	}
	// MARK: UI controls
	
	@IBAction func unwindToClassViewController(segue: UIStoryboardSegue) {
		print("unwinding to class view")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavigationBar()
		
		configureDatabase()
		configureStorage()
		configureRemoteConfig()
		fetchConfig()
//		self.tableView.registerClass(MessageViewCell.self, forCellReuseIdentifier: "MessageCell")
		//TODO:-Cells and figure this out
		loadAd()
		logViewLoaded()

		// Listen for keyboard events and animate text field as necessary
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardWillShow(_:)),
		                                                 name:UIKeyboardWillShowNotification,
		                                                 object: nil);
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardDidShow(_:)),
		                                                 name:UIKeyboardDidShowNotification,
		                                                 object: nil);
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(ClassViewController.keyboardWillHide(_:)),
		                                                 name:UIKeyboardWillHideNotification,
		                                                 object: nil);
		
		// Set up UI controls
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 66.0
		self.tableView.separatorStyle = .None
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.Segues.CramChatToSettings
		{
			let vc = segue.destinationViewController as! ClassSettingsViewController
			vc.navigationItem.leftItemsSupplementBackButton = true
		}
		else if segue.identifier! == Constants.Segues.CramChatToCrammateAddition
		{
			let vc = segue.destinationViewController as! CrammateAdditionViewController
			vc.cramClass = self.cramChat
			vc.navigationItem.leftItemsSupplementBackButton = true
			vc.title = "Add Crammates"
		}

	}
	
		

	// MARK: Firebase stuff
		
	@IBAction func didPressFreshConfig(sender: AnyObject) {
		fetchConfig()
	}
	
	@IBAction func didSendMessage(sender: UIButton) {
		textFieldShouldReturn(textField)
	}
	
	@IBAction func didPressCrash(sender: AnyObject) {
		FIRCrashMessage("Cause Crash button clicked")
		fatalError("asdf")
	}
	
	func logViewLoaded() {
		FIRCrashMessage("View loaded")
	}
	//TODO: add ad view
	func loadAd() {
//		self.banner.adUnitID = kBannerAdUnitID
//		self.banner.rootViewController = self
//		self.banner.loadRequest(GADRequest())
	}
	func sendMessage(data: [String: String]) {
		var mdata = data
		mdata[Constants.MessageFields.name] = AppState.sharedInstance.displayName
		if let photoUrl = AppState.sharedInstance.photoUrl {
			mdata[Constants.MessageFields.photoUrl] = photoUrl.absoluteString
		}
		// Push data to Firebase Database
		self.messagesRef.childByAutoId().setValue(mdata)
		//Send to Analytics
		MeasurementHelper.sendMessageEvent()
	}
	
	deinit {
		self.messagesRef.removeAllObservers()
	}
	
	// UITableViewDataSource protocol methods
		
	
}