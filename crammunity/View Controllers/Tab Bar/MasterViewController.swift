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
		self.navigationItem.leftBarButtonItem = self.editButtonItem

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_: )))
		self.navigationItem.rightBarButtonItem = addButton
		_addHandle = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("classes").observe(.childAdded, with: { (snapshot) -> Void in
			self.classes.insert(snapshot, at: 0)
			let indexPath = IndexPath(row: 0, section: 0)
			self.tableView.insertRows(at: [indexPath], with: .automatic)
			
		})
		_removeHandle = Constants.Firebase.UserArray.child((Constants.Firebase.currentUser.uid)).child("classes").observe(.childRemoved, with: { (snapshot) -> Void in
			var i = 0
			for snap in self.classes{
				if ((snap.value as AnyObject).value(forKey: CramClassFKs.name)) as! String == ((snapshot.value as AnyObject).value(forKey: CramClassFKs.name)) as! String
				{
					self.classes.remove(at: i)
					break
				}
				i += 1
			}
			
			self.tableView.reloadData()
		})
		
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	deinit {
		Constants.Firebase.CramClassArray.removeAllObservers()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(_ sender: AnyObject) {
//		self.tableView.editing = false
		performSegue(withIdentifier: "MainToClassCreation", sender: sender)

	}
	
	
	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		self.tableView.isEditing = false
		
		if segue.identifier == Constants.Segues.MainToClassChat
		{
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let personalCramClass = classes[indexPath.row]
				let cramclass = Constants.Firebase.CramClassArray.child(personalCramClass.key)
				
				let controller = (segue.destination) as! ClassViewController
				
				controller.titleBar.title = ((personalCramClass.value as AnyObject).value(forKey: "className") as? String)!// + ": " + (controller.currentChapter ?? "")
				//TODO: change to update chapter somehow
				
				//TODO: consider making Class, classname, calculated values off of snapshot
				controller.classRef = cramclass
				controller.classUID = personalCramClass.key
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
	
	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return classes.count
	}

	//TODO: get unread messages, maybe number of members
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassViewCell
		
		cell.textLabel!.text = (classes[indexPath.section].value! as AnyObject).value(forKey: CramClassFKs.name) as? String
		
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	//class deletion
	//TODO: remove other users?
	//change to in menu
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			//TODO: why doesnt this exit
			FirebaseHelper.removeCurrentUserFromClass(classes[indexPath.row])
//		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .insert {
		    print("inserted")
		}
	}


}

