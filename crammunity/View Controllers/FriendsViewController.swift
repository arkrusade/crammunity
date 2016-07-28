//
//  FriendsViewController.swift
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

class FriendsViewController: UIViewController
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


	var _usersHandle: FIRDatabaseHandle!
	var _friendsHandle: FIRDatabaseHandle!
	var _removeFriendsHandle: FIRDatabaseHandle!
	
	
	//whenever a query changes, update the list and handlers
	var friendsQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			notFriendTableView.reloadData()
			friendTableView.reloadData()
			friends = []
			
			_friendsHandle = friendsQuery!.observeEventType(.ChildAdded, withBlock: { snapshot in
				if snapshot.exists() {
					self.friends.append(snapshot)
					self.friendsUIDS.append(snapshot.key)
					
					self.notFriends = self.notFriends.filter({$0.key != snapshot.key})
				} else {
					print("error in friend loading")
				}
			})
			_removeFriendsHandle = friendsQuery!.observeEventType(.ChildRemoved, withBlock: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.friends = self.friends.filter({$0.key != snapshot.key})
					self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
					
					self.notFriends.append(snapshot)
				} else {
					print("error in friend removing")
				}
			})
		}
	}
	
	// the current parse query
	var usersQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			notFriendTableView.reloadData()
			friendTableView.reloadData()
			notFriends = []
			_usersHandle = usersQuery!.observeEventType(.ChildAdded, withBlock: { snapshot in
				if snapshot.exists() {
					if !(snapshot.key == FIRAuth.auth()?.currentUser!.uid || self.friendsUIDS.contains(snapshot.key))
					{
						self.notFriends.append(snapshot)
					}
				} else {
					print("error in user loading")
				}
			})
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
				usersQuery = FirebaseHelper.usersQuery()
				friendsQuery = FirebaseHelper.friendsQuery()
				
			case .SearchMode:
				let searchText = searchBar?.text ?? ""
				usersQuery = FirebaseHelper.usersQuery(searchText)
				friendsQuery = FirebaseHelper.friendsQuery(searchText)

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
		friends = []
		notFriends = []
	}
}

// MARK: Searchbar Delegate

extension FriendsViewController: UISearchBarDelegate {
	
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
		usersQuery = FirebaseHelper.usersQuery(searchText)
		friendsQuery = FirebaseHelper.friendsQuery(searchText)

	}
}

// MARK: FriendTableViewCell Delegate

extension FriendsViewController: FriendSearchViewCellDelegate {
	
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