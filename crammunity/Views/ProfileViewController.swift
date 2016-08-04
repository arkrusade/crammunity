//
//  ProfileViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 8/3/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
	var user: FIRDataSnapshot! {
		didSet{
			//TODO
		}
	}
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var displayNameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var gradeLabel: UILabel!


	
	@IBOutlet weak var profileImageView: UIImageView!
	
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
