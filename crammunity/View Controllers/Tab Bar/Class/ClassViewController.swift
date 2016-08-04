//
//  ClassViewController.swift
//  IPMQuickstart
//
//  Created by Kevin Whinnery on 12/9/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit
import UIKit

import Firebase
import GoogleMobileAds

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@objc(ClassViewController)
class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UINavigationControllerDelegate {
	
	
	// Instance variables
	@IBOutlet weak var sendButton: UIButton!
	var messagesRef: FIRDatabaseReference!
	var messages: [FIRDataSnapshot]! = []
	var msglength: NSNumber = 10
	private var _refHandle: FIRDatabaseHandle!
	
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
		let settingsBarButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(goToClassSettings(_: )))

		self.navigationItem.rightBarButtonItems = [settingsBarButton, addFriendsBarButton]
		
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
	
	// MARK: Keyboard Dodging Logic
	func keyboardWillShow(notification: NSNotification) {
		let keyboardHeight = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.height
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			self.bottomConstraint.constant = keyboardHeight! + self.lengthOfBottomConstraint - (self.tabBarController?.tabBar.frame.height)!
			self.view.layoutIfNeeded()
		})
	}
	
	func keyboardDidShow(notification: NSNotification) {
		self.scrollToBottomMessage()
	}
	
	func keyboardWillHide(notification: NSNotification) {
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			self.bottomConstraint.constant = self.lengthOfBottomConstraint
			self.view.layoutIfNeeded()
		})
	}
	
	// MARK: UI Logic
	
	// Dismiss keyboard if container view is tapped
	@IBAction func viewTapped(sender: AnyObject) {
		self.textField.resignFirstResponder()
	}
	
	// Scroll to bottom of table view for messages
	func scrollToBottomMessage() {
		if self.messages.count == 0 {
			return
		}
		let bottomMessageIndex = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
		                                     inSection: 0)
		self.tableView.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
		                                      animated: true)
	}
	// MARK: Firebase stuff
	deinit {
		self.messagesRef.removeAllObservers()
	}
	
	func configureDatabase() {
		messagesRef = Constants.Firebase.CramClassArray.child(cramChat.key).child(CramClassFKs.MessagesArray)
		
		//find new messages
		_refHandle = messagesRef.observeEventType(.ChildAdded, withBlock: { snapshot in
				if snapshot.exists() {
					self.messages.append(snapshot)
					self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)

				} else {
					print("error in message loading")
					
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
				print("Config not fetched")
				print("Error \(error)")
			}
		}
	}
	
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
		// UITextViewDelegate protocol methods
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		let data = [Constants.MessageFields.text: textField.text! as String]
		sendMessage(data)
		textField.text! = ""
		return true
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
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= self.msglength.integerValue // Bool
	}
	
	// UITableViewDataSource protocol methods
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	

	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Dequeue cell
		let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageViewCell
		
		
		//TODO:-Cells as constants
		// Unpack message from Firebase DataSnapshot
		let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
		let message = messageSnapshot.value as! Dictionary<String, String>
		let name = message[Constants.MessageFields.name] as String!
		cell.displayName = name
		if message["isReported"] == "true"
		{
			cell.isReported = true
		}
		else if let imageUrl = message[Constants.MessageFields.imageUrl] {
			var image = Constants.Images.defaultProfile
			if imageUrl.hasPrefix("gs://") {
				FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
					if let error = error {
						print("Error downloading: \(error)")
						self.showAlert("Error downloading image", message: error.description)

						return
					}
					image = UIImage(data: data!)
					cell.profileImageView?.image = image
					cell.displayName = "sent by: \(name)"
					cell.message = ""
				}
			}
			
			else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
				cell.imageView?.image = UIImage.init(data: data)
			}
			cell.profileImageView?.image = image
			cell.message = "loading..."
			cell.displayName = "Image is"
		}
		
		
		
		
		else {
			let text = message[Constants.MessageFields.text] as String!
			if name != nil
			{
				cell.displayName = name + ": "
				cell.message = text
				cell.profileImageView?.image = Constants.Images.defaultProfile

				if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
					cell.imageView?.image = UIImage(data: data)
				}
			}
			else{
				print("missing name")
			}
		}
		
		cell.messageRef = messageSnapshot.ref
		cell.presentingViewController = self
		return cell
	}
	
	
}