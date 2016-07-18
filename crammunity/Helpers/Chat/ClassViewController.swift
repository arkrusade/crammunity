//
//  ClassViewController.swift
//  IPMQuickstart
//
//  Created by Kevin Whinnery on 12/9/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit
import Photos
import UIKit

import Firebase
import GoogleMobileAds

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@objc(ClassViewController)
class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	// Instance variables
	@IBOutlet weak var sendButton: UIButton!
	var rootRef: FIRDatabaseReference!
	var messagesRef: FIRDatabaseReference!
	var messages: [FIRDataSnapshot]! = []
	var msglength: NSNumber = 10
	private var _refHandle: FIRDatabaseHandle!
	
	var storageRef: FIRStorageReference!
	var remoteConfig: FIRRemoteConfig!
	
	@IBOutlet weak var banner: GADBannerView!
	
	
//	@IBOutlet weak var titleBar: UINavigationItem!
//	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
//	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var titleBar: UINavigationItem!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	let lengthOfBottomConstraint: CGFloat = 10
	@IBOutlet weak var textField: UITextField!
	
	// MARK: Class naming
	var classChat: Class!
	var cramChat: FIRDataSnapshot!
	//TODO: Change to loading inside of class view instead of sending to view
	
	func configureView() {
//		// Update the user interface for the detail item.
		if let classTitle = self.classChat {
			titleBar.title = classTitle.className
			
		}
		
	}
	
	// MARK: UI controls
	
	@IBAction func unwindToClassViewController(segue: UIStoryboardSegue) {
		print("unwinding to class view")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
		
		configureDatabase()
		configureStorage()
		configureRemoteConfig()
		fetchConfig()
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")

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
	
	// MARK: Keyboard Dodging Logic
	func keyboardWillShow(notification: NSNotification) {
		let keyboardHeight = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.height
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			self.bottomConstraint.constant = keyboardHeight! + self.lengthOfBottomConstraint
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
	//TODO: add tapped controller
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
		self.messagesRef.removeObserverWithHandle(_refHandle)
	}
	
	func configureDatabase() {
		rootRef = FIRDatabase.database().reference()
		messagesRef = rootRef.child(Constants.Firebase.CramClassArray).child(cramChat.key).child("messages")
		
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
		// Enabling developer mode allows many more requests to be made per hour, so developers
		// can test different config values during development.
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
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else { return true }
		
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= self.msglength.integerValue // Bool
	}
	
	// UITableViewDataSource protocol methods
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
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
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Dequeue cell
		let cell: UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath)
		// Unpack message from Firebase DataSnapshot
		let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
		let message = messageSnapshot.value as! Dictionary<String, String>
		let name = message[Constants.MessageFields.name] as String!
		if let imageUrl = message[Constants.MessageFields.imageUrl] {
			if imageUrl.hasPrefix("gs://") {
				FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
					if let error = error {
						print("Error downloading: \(error)")
						return
					}
					cell.imageView?.image = UIImage.init(data: data!)
				}
			} else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
				cell.imageView?.image = UIImage.init(data: data)
			}
			cell!.textLabel?.text = "sent by: \(name)"
		} else {
			let text = message[Constants.MessageFields.text] as String!
			if name != nil
			{
				cell!.textLabel?.text = name + ": " + text
				cell!.imageView?.image = UIImage(named: "ic_account_circle")
				if let photoUrl = message[Constants.MessageFields.photoUrl], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
					cell!.imageView?.image = UIImage(data: data)
				}
			}
			else{
				print("missing name")
			}
		}
		return cell!
	}
	
	
	
	// MARK: - Image Picker
	//TODO: add image button
	@IBAction func didTapAddPhoto(sender: AnyObject) {
		let picker = UIImagePickerController()
		picker.delegate = self
		if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
			picker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		
		presentViewController(picker, animated: true, completion:nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		picker.dismissViewControllerAnimated(true, completion:nil)
		
		// if it's a photo from the library, not an image from the camera
		if /*#available(iOS 8.0, *),*/ let referenceUrl = info[UIImagePickerControllerReferenceURL] {
			let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)
			let asset = assets.firstObject
			asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
				let imageFile = contentEditingInput?.fullSizeImageURL
				let filePath = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
				self.storageRef.child(filePath)
					.putFile(imageFile!, metadata: nil) { (metadata, error) in
						if let error = error {
							print("Error uploading: \(error.description)")
							return
						}
						self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
				}
			})
		} else {
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			let imageData = UIImageJPEGRepresentation(image, 0.8)
			let imagePath = FIRAuth.auth()!.currentUser!.uid +
				"/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			self.storageRef.child(imagePath)
				.putData(imageData!, metadata: metadata) { (metadata, error) in
					if let error = error {
						print("Error uploading: \(error)")
						return
					}
					self.sendMessage([Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
			}
		}
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion:nil)
	}
	
	
	func showAlert(title:String, message:String) {
		dispatch_async(dispatch_get_main_queue()) {
			let alert = UIAlertController(title: title,
			                              message: message, preferredStyle: .Alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
			alert.addAction(dismissAction)
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	
}


