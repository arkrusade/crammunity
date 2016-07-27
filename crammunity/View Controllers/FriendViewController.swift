//
//  FriendViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/22/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol FriendSearchViewCellDelegate: class {
	func cell(cell: FriendSearchViewCell, didSelectFriendUser user: FIRDataSnapshot)
	func cell(cell: FriendSearchViewCell, didSelectUnFriendUser user: FIRDataSnapshot)
}

class FriendViewController: UIViewController
{
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var notFriendTableView: UITableView!
	@IBOutlet weak var friendTableView: UITableView!
	
	var notFriends: [FIRDataSnapshot] = []{
		didSet{
			notFriendTableView.reloadData()
		}
	}
	var friends: [FIRDataSnapshot] = []{
		didSet{
			friendTableView.reloadData()
		}
	}
	var friendsUIDS: [String] = []

	
	var usersRef: FIRDatabaseReference?
	var friendsRef: FIRDatabaseReference?
	var _usersHandle: FIRDatabaseHandle!
	var _friendsHandle: FIRDatabaseHandle!
	var _removeFriendsHandle: FIRDatabaseHandle!

	
	// the current parse query
	var query: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
		}
	}
	
//	// this view can be in two different states
	enum State {
		case DefaultMode
		case SearchMode
	}
//
//	// whenever the state changes, perform one of the two queries and update the list
	var state: State = .DefaultMode {
		didSet {
			switch (state) {
			case .DefaultMode:
				query = FirebaseHelper.allUsers()
				
			case .SearchMode:
				let searchText = searchBar?.text ?? ""
				query = FirebaseHelper.allUsers(searchText)
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

		usersRef = Constants.Firebase.UserArray
		friendsRef = Constants.Firebase.UserArray.child((Constants.currentUser.uid)).child("friends")
		
		//find users
		_friendsHandle = friendsRef!.observeEventType(.ChildAdded, withBlock: { snapshot in
			if snapshot.exists() {
				self.friends.append(snapshot)
				self.friendsUIDS.append(snapshot.key)
				
				self.notFriends = self.notFriends.filter({$0.key != snapshot.key})
				//				self.friendTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.friends.count-1, inSection: 0)], withRowAnimation: .None)
			} else {
				print("error in friend loading")
			}
		})
		_removeFriendsHandle = friendsRef!.observeEventType(.ChildRemoved, withBlock: { snapshot in
			if snapshot.exists() {
				self.friends = self.friends.filter({$0.key != snapshot.key})
				self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})

				self.notFriends.append(snapshot)
				//				self.friendTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.friends.count-1, inSection: 0)], withRowAnimation: .None)
//				self.friendTableView.reloadData()
				
			} else {
				print("error in friend removing")
			}
		})
		
		_usersHandle = usersRef!.observeEventType(.ChildAdded, withBlock: { snapshot in
			if snapshot.exists() {
				if !(snapshot.key == Constants.currentUser.uid || self.friendsUIDS.contains(snapshot.key))
				{
					self.notFriends.append(snapshot)
					
//					self.notFriendTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.notFriends.count-1, inSection: 0)], withRowAnimation: .None)
					
//					self.friendTableView.reloadData()
//					self.tableView.reloadData()
				}
			} else {
				print("error in user loading")
			}
		})
		
		
		
	}
	
	
	deinit {
		if let usersRef = usersRef {
			usersRef.removeAllObservers()
		}
		if let friendsRef = friendsRef
		{
			friendsRef.removeAllObservers()
		}
	}
}

// MARK: TableView Data Source

extension FriendViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
			// 1
			// Return the number of sections.
			return 1
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		let headerCell: CustomHeaderCell
		if tableView == self.notFriendTableView
		{
//			headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
//			headerCell.titleLabel.text = "Users"
			
			return "Users"
		}
		else
		{
			return "Friends"
		}
		
		
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count: Int?
		if tableView == self.notFriendTableView
		{
			count = self.notFriends.count
		}
		else
		{
			count = self.friends.count
		}
		return count!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: FriendSearchViewCell
		
		if tableView == self.notFriendTableView {
			cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! FriendSearchViewCell
			let user = notFriends[indexPath.row]
			cell.user = user
			cell.usernameLabel.text = user.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isFriend = false
			return cell
		}
		
		else
		{ 
			cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendSearchViewCell
			let friend = friends[indexPath.row]
			cell.user = friend
			cell.usernameLabel.text = friend.value!.valueForKey("username") as? String
			cell.imageView?.image = Constants.Images.defaultProfile
			cell.delegate = self
			
			cell.isFriend = true
			return cell
		}
		
		
	}
}

// MARK: Searchbar Delegate

extension FriendViewController: UISearchBarDelegate {
	
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
		FirebaseHelper.allUsers(searchText)
	}
	
}

// MARK: FriendTableViewCell Delegate

extension FriendViewController: FriendSearchViewCellDelegate {
	
	func cell(cell: FriendSearchViewCell, didSelectFriendUser user: FIRDataSnapshot) {
		//set friends in database
		Constants.Firebase.UserArray.child(user.key).observeSingleEventOfType(.Value) { (snapshot) -> Void in
			FirebaseHelper.addFriend(snapshot)
		}

	}
	
	func cell(cell: FriendSearchViewCell, didSelectUnFriendUser user: FIRDataSnapshot) {
		Constants.Firebase.UserArray.child(user.key).child("friends").child(user.key).observeSingleEventOfType(.Value) { (snapshot) -> Void in
			FirebaseHelper.removeFriend(snapshot)
		}
	}
	
}