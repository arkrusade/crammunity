//
//  ProfileViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/26/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {
	
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
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
