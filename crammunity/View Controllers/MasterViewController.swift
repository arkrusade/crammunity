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
	var classes: [FIRDataSnapshot] = []
	var _addHandle: FIRDatabaseHandle!
	var _removeHandle: FIRDatabaseHandle!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
		_addHandle = Constants.Firebase.CramClassArray.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
			self.classes.insert(snapshot, atIndex: 0)
			let indexPath = NSIndexPath(forRow: 0, inSection: 0)
			self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			
		})
		_removeHandle = Constants.Firebase.CramClassArray.observeEventType(.ChildRemoved, withBlock: { (snapshot) -> Void in
			var i = 0
			for snap in self.classes{
				if FirebaseHelper.getStringFromDatabaseKey("name", snapshot: snap) == FirebaseHelper.getStringFromDatabaseKey("name", snapshot: snapshot)
				{
					self.classes.removeAtIndex(i)
					break
				}
				i += 1
			}
			
			self.tableView.reloadData()
		})
		
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	deinit {
		Constants.Firebase.CramClassArray.removeAllObservers()
//		if _addHandle != nil
//		{
//			Constants.Firebase.rootRef.child(Constants.Firebase.CramClassArray).removeObserverWithHandle(_addHandle)
//		}
//		if _removeHandle != nil
//		{
//			Constants.Firebase.rootRef.child(Constants.Firebase.CramClassArray).removeObserverWithHandle(_removeHandle)
//		}
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
//TODO: edit cramclass creation
	func insertNewObject(sender: AnyObject) {

		performSegueWithIdentifier("MainToClassCreation", sender: nil)

	}
	
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
		
		cell.textLabel!.text = FirebaseHelper.getStringFromDatabaseKey(Constants.CramClass.Name, snapshot: classes[indexPath.section])
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			Constants.Firebase.CramClassArray.child(classes[indexPath.row].key).removeValue()

			classes.removeAtIndex(indexPath.row)
			
		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
		    print("inserted")
		}
	}


}

