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
	var notFriendsUIDS: [String] = []

	var _usersHandle: FIRDatabaseHandle!
	var _friendsHandle: FIRDatabaseHandle!
	var _removeFriendsHandle: FIRDatabaseHandle!
	var _removeUsersHandle: FIRDatabaseHandle!
	
	
	//whenever a query changes, update the list and handlers
	var friendsQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			notFriendTableView.reloadData()
			friendTableView.reloadData()
			friends = []
			friendsUIDS = []
			_friendsHandle = friendsQuery!.observe(.childAdded, with: { snapshot in
				if snapshot.exists() {
					self.friends.append(snapshot)
					self.friendsUIDS.append(snapshot.key)
					
					self.notFriends = self.notFriends.filter({$0.key != snapshot.key})
					self.notFriendsUIDS = self.notFriendsUIDS.filter({$0 != snapshot.key})
				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed friend loading", sender: self)
				}
			})
			_removeFriendsHandle = friendsQuery!.observe(.childRemoved, with: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.friends = self.friends.filter({$0.key != snapshot.key})
					self.friendsUIDS = self.friendsUIDS.filter({$0 != snapshot.key})
					
					self.notFriends.append(snapshot)
					self.notFriendsUIDS.append(snapshot.key)

				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed friend removing", sender: self)
				}
			})
		}
	}
	
	//TODO: change to display requests instead of all users
	var usersQuery: FIRDatabaseQuery? {
		didSet {
			// whenever we assign a new query, cancel any previous requests
			// you can use oldValue to access the previous value of the property
			oldValue?.removeAllObservers()
			notFriendTableView.reloadData()
			friendTableView.reloadData()
			notFriends = []
			notFriendsUIDS = []
			_usersHandle = usersQuery!.observe(.childAdded, with: { snapshot in
				if snapshot.exists() {
					if !(snapshot.key == Constants.Firebase.currentUser.uid || self.friendsUIDS.contains(snapshot.key))
					{
						self.notFriends.append(snapshot)
						self.notFriendsUIDS.append(snapshot.key)

					}
				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed user loading", sender: self)
				}
			})
			_removeUsersHandle = usersQuery!.observe(.childRemoved, with: { snapshot in
				if snapshot.exists() {
					//TODO: change to didset?
					self.notFriends = self.notFriends.filter({$0.key != snapshot.key})
					self.notFriendsUIDS = self.notFriendsUIDS.filter({$0 != snapshot.key})
				} else {
                    ErrorHandling.defaultError("Error", desc: "Failed user removing", sender: self)
				}
			})
		}
	}
	
//	// this view can be in two different states
	enum State {
		case defaultMode
		case searchMode
	}
//
//	// whenever the state changes, perform one of the two queries
	var state: State = .defaultMode {
		didSet {
			switch (state) {
			case .defaultMode:
				usersQuery = FirebaseHelper.shared.emptyQuery()
				friendsQuery = FirebaseHelper.shared.emptyQuery()
				
			case .searchMode:
                if let searchText = searchBar?.text, searchText != "" {
                    usersQuery = FirebaseHelper.shared.usersQuery(byUsername: searchText)
                    friendsQuery = FirebaseHelper.shared.friendsQuery(byUsername: searchText)
                }
                else {
                    usersQuery = FIRDatabaseQuery()
                    friendsQuery = FIRDatabaseQuery()
                }

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
//			ErrorHandling.defaultError(error)
//		}
//		self.users = results as? [PFUser] ?? []
//		self.tableView.reloadData()
//		
//	}
	
	// MARK: View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		searchBarCancelButtonClicked(searchBar)
	}
	deinit {
		friends = []
		notFriends = []
		friendsQuery = nil
        usersQuery = nil
	}
}

// MARK: Searchbar Delegate

extension FriendsViewController: UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
		state = .searchMode
	}
	
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		state = .defaultMode
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        state = .searchMode
	}
}

protocol FriendSearchViewCellDelegate: class {
	func cell(_ cell: FriendSearchViewCell, didSelectFriendUser user: FIRDataSnapshot)
	func cell(_ cell: FriendSearchViewCell, didSelectUnFriendUser user: FIRDataSnapshot)
}
// MARK: FriendTableViewCell Delegate

extension FriendsViewController: FriendSearchViewCellDelegate {
	
	func cell(_ cell: FriendSearchViewCell, didSelectFriendUser user: FIRDataSnapshot) {
		//set friends in database
		Constants.Firebase.UserArray.child(user.key).observeSingleEvent(of: .value) { (snapshot) -> Void in
			FirebaseHelper.shared.addFriend(snapshot)
		}
	}
	
	func cell(_ cell: FriendSearchViewCell, didSelectUnFriendUser user: FIRDataSnapshot) {
		Constants.Firebase.UserArray.child(user.key).child("friends").child(user.key).observeSingleEvent(of: .value) { (snapshot) -> Void in
			FirebaseHelper.shared.removeFriend(snapshot)
		}
	}
	
}
