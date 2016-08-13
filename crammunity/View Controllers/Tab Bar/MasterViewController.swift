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
		
		//TODO: add search class functionality
		//TODO: prevent duplicate classes
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_: )))
		self.navigationItem.rightBarButtonItem = addButton
		_addHandle = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("classes").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
			self.classes.insert(snapshot, atIndex: 0)
			let indexPath = NSIndexPath(forRow: 0, inSection: 0)
			self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			
		})
		_removeHandle = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("classes").observeEventType(.ChildRemoved, withBlock: { (snapshot) -> Void in
			var i = 0
			for snap in self.classes{
				if (snap.value?.valueForKey(CramClassFKs.name)) as! String == (snapshot.value?.valueForKey(CramClassFKs.name)) as! String
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
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
//		self.tableView.editing = false
		performSegueWithIdentifier("MainToClassCreation", sender: sender)

	}
	
	
	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.tableView.editing = false
		
		if segue.identifier == Constants.Segues.MainToClassChat
		{
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let personalCramClass = classes[indexPath.row]
				let cramclass = Constants.Firebase.CramClassArray.child(personalCramClass.key)
				
				let controller = (segue.destinationViewController) as! ClassViewController
				
				controller.titleBar.title = (personalCramClass.value?.valueForKey("className") as? String)!// + ": " + (controller.currentChapter ?? "")
				//TODO: change to update chapter somehow
				
				//TODO: consider making Class, classname, calculated values off of snapshot
				controller.classRef = cramclass
				controller.classUID = personalCramClass.key
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

	//TODO: get unread messages, maybe number of members
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! ClassViewCell
		
		cell.textLabel!.text = classes[indexPath.section].value!.valueForKey(CramClassFKs.name) as? String
		
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	//class deletion
	//TODO: remove other users?
	//change to in menu
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			//TODO: why doesnt this exit
			FirebaseHelper.removeCurrentUserFromClass(classes[indexPath.row])
//		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
		    print("inserted")
		}
	}


}

