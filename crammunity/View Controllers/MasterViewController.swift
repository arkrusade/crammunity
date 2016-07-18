//
//  MasterViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 6/29/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
class MasterViewController: UITableViewController {

	var topViewController: ClassViewController? = nil
	var objects = [Class]()
	var classes: [FIRDataSnapshot] = []
	var _refHandle: FIRDatabaseHandle!
	let ref = FIRDatabase.database().reference()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

//		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
//		self.navigationItem.rightBarButtonItem = addButton
		_refHandle = self.ref.child(Constants.Firebase.CramClassArray).observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
			print(FirebaseHelper.getStringFromDatabaseKey(Constants.CramClass.CramClassName, snapshot: snapshot))
			//TODO: implemet method to sync classes and table view
			self.classes.insert(snapshot, atIndex: 0)
			let indexPath = NSIndexPath(forRow: 0, inSection: 0)
			self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

		})
		
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	deinit {
		self.ref.child(Constants.Firebase.CramClassArray).removeObserverWithHandle(_refHandle)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
//TODO: add segue to cramclass creation window
//TODO: add cramclass creation
//	func insertNewObject(sender: AnyObject) {
//		//TODO: add proper saving to datbase
//		classes.insert(FIRDataSnapshot(), atIndex: 0)
//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//	}
	
	//TODO: add signout
	@IBAction func signOut(sender: AnyObject) {
		let firebaseAuth = FIRAuth.auth()
		do {
			try firebaseAuth?.signOut()
			AppState.sharedInstance.signedIn = false
			MeasurementHelper.sendLogoutEvent()//send to analytics
			dismissViewControllerAnimated(true, completion: nil)
		} catch let signOutError as NSError {
			print ("Error signing out: \(signOutError)")
		}
	}
	
	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.Segues.MainToClassChat
		{
//			if let indexPath = self.tableView.indexPathForSelectedRow {
//				let object = objects[indexPath.row]
//				let controller = (segue.destinationViewController) as! ClassViewController
//				controller.classChat = object
//				controller.navigationItem.leftItemsSupplementBackButton = true
//			}
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let cramclass = classes[indexPath.row]
				let controller = (segue.destinationViewController) as! ClassViewController
				controller.classChat = Class(cramClass: cramclass)
				//TODO: Change to loading inside of class view instead of sending to view

				controller.cramChat = cramclass
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return classes.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! ClassViewCell
//		cell.textLabel!.text = objects[indexPath.section].className
//		cell.thisClass = objects[indexPath.section]
		cell.textLabel!.text = FirebaseHelper.getStringFromDatabaseKey(Constants.CramClass.CramClassName, snapshot: classes[indexPath.section])
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			classes.removeAtIndex(indexPath.row)
		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}


}

