//
//  CrammateAdditionViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/22/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol CrammateAdditionViewCellDelegate: class {
	func cell(cell: CrammateSearchViewCell, didSelectAddCrammateUser user: FIRDataSnapshot)
	func cell(cell: CrammateSearchViewCell, didSelectRemoveCrammateUser user: FIRDataSnapshot)
}


class CrammateAdditionViewController: UIViewController
{
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var friendsTableView: UITableView!
	@IBOutlet weak var crammatesTableView: UITableView!
	
	var friends: [FIRDataSnapshot] = []{
		didSet{
			friendsTableView.reloadData()
		}
	}
	var crammates: [FIRDataSnapshot] = []{
		didSet{
			crammatesTableView.reloadData()
		}
	}
	var crammatesUIDS: [String] = []
	var friendsUIDS: [String] = []
	var cramClass: FIRDatabaseReference?
	
	
	var _friendsHandle: FIRDatabaseHandle!
	var _crammatesHandle: FIRDatabaseHandle!
	var _removeCrammatesHandle: FIRDatabaseHandle!
	var _removeFriendsHandle: FIRDatabaseHandle!
	
	
	//whenever a query changes, update the list and handlers
	var crammatesQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			
			crammates = []
			crammatesUIDS = []
			
			_crammatesHandle = crammatesQuery!.observeEventType(.ChildAdded, withBlock: { snapshot in
				if snapshot.exists() {
					if !(snapshot.key == FIRAuth.auth()?.currentUser!.uid) {
						self.crammates.append(snapshot)
						self.crammatesUIDS.append(snapshot.key)
						self.friends = self.friends.filter({$0.key != snapshot.key})
						self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
					}
				} else {
					print("error in crammate loading")
				}
			})
			_removeCrammatesHandle = crammatesQuery!.observeEventType(.ChildRemoved, withBlock: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.crammates = self.crammates.filter({$0.key != snapshot.key})
					self.crammatesUIDS = self.crammatesUIDS.filter({$0 != snapshot.key})
					
					self.friends.append(snapshot)
					self.friendsUIDS.append(snapshot.key)
				} else {
					print("error in crammate removing")
				}
			})
			friendsTableView.reloadData()
			crammatesTableView.reloadData()
		}
	}
	
	// the current parse query
	var friendsQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			
			friends = []
			friendsUIDS = []
			_friendsHandle = friendsQuery!.observeEventType(.ChildAdded, withBlock: { snapshot in
				if snapshot.exists() {
					if !(self.crammatesUIDS.contains(snapshot.key) || snapshot.key == FIRAuth.auth()?.currentUser!.uid)
					{
						self.friends.append(snapshot)
						self.friendsUIDS.append(snapshot.key)
					}
				} else {
					print("error in user loading")
				}
			})
			_removeFriendsHandle = friendsQuery!.observeEventType(.ChildRemoved, withBlock: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.friends = self.friends.filter({$0.key != snapshot.key})
					self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
				} else {
					print("error in friend removing")
				}
			})
			friendsTableView.reloadData()
			crammatesTableView.reloadData()
		}
	}
	
	//	// this view can be in two different states
	enum State {
		case DefaultMode
		case SearchMode
	}
	//
	//	// whenever the state changes, perform one of the two queries
	var state: State = .DefaultMode {
		didSet {
			switch (state) {
			case .DefaultMode:
				friendsQuery = FirebaseHelper.friendsQuery()
				crammatesQuery = FirebaseHelper.crammatesQuery(cramClass!)
				
			case .SearchMode:
				let searchText = searchBar?.text ?? ""
				friendsQuery = FirebaseHelper.friendsQuery(searchText)
				crammatesQuery = FirebaseHelper.crammatesQuery(cramClass!, byUsername: searchText)
				
			}
		}
	}
	
	// MARK: Update userlist
	
	/**
	Is called as the completion block of all queries.
	As soon as a query completes, this method updates the Table View.
	*/
	//	func updateList(results: [PFObject]?, error: NSError?) {
	//		if let error = error {
	//			ErrorHandling.defaultErrorHandler(error)
	//		}
	//		self.users = results as? [PFUser] ?? []
	//		self.tableView.reloadData()
	//
	//	}
	
	// MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		state = .DefaultMode
	}
	deinit {
		crammates = []
		friends = []
	}
	
	@IBAction func unwindToClassViewControllerFromCrammateAddition(segue: UIButton) {
		print("unwinding to class view from crammate addition")
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}

// MARK: Searchbar Delegate

extension CrammateAdditionViewController: UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
		state = .SearchMode
	}
	
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		state = .DefaultMode
	}
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		friendsQuery = FirebaseHelper.friendsQuery(searchText)
		crammatesQuery = FirebaseHelper.crammatesQuery(cramClass!, byUsername: searchText)
		
	}
}

// MARK: CrammateAdditionViewController Delegate

extension CrammateAdditionViewController: CrammateAdditionViewCellDelegate {
	
	func cell(cell: CrammateSearchViewCell, didSelectAddCrammateUser user: FIRDataSnapshot) {
		//set crammates in database
		Constants.Firebase.UserArray.child(user.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
			FirebaseHelper.addUserToClass(snapshot, cramClass: self.cramClass!)
		})
	}
	
	func cell(cell: CrammateSearchViewCell, didSelectRemoveCrammateUser user: FIRDataSnapshot) {
		Constants.Firebase.UserArray.child(user.key).child("friends").child(user.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
			FirebaseHelper.removeUserFromClass(snapshot, cramClass: self.cramClass!)
		})
	}
	
}




// MARK: TableView Data Source
extension CrammateAdditionViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// 1
		// Return the number of sections.
		return 1
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView == self.crammatesTableView
		{
			return "Crammates"
		}
		else
		{
			return "Friends"
		}
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count: Int?
		if tableView == self.friendsTableView
		{
			count = self.friends.count
		}
		else
		{
			count = self.crammates.count
		}
		return count!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: CrammateSearchViewCell
		
		if tableView == self.friendsTableView {
			cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! CrammateSearchViewCell
			let user = friends[indexPath.row]
			cell.user = user
			cell.usernameLabel.text = user.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isClassmate = false
			return cell
		}
		else
		{
			cell = tableView.dequeueReusableCellWithIdentifier("CrammateCell", forIndexPath: indexPath) as! CrammateSearchViewCell
			let crammate = crammates[indexPath.row]
			cell.user = crammate
			cell.usernameLabel.text = crammate.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isClassmate = true
			return cell
		}
	}
}
