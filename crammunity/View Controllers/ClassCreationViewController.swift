//
//  ClassCreationViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/18/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class ClassCreationViewController: UIViewController {

	@IBOutlet weak var newClassNameTextField: UITextField!
	@IBOutlet weak var createClassButton: UIButton!
	
	@IBAction func onCreateClassTap(sender: AnyObject) {
		
//TODO: add cancel button
		
		if !self.newClassNameTextField.text!.isEmpty {
			FirebaseHelper.createClass(self.newClassNameTextField.text!)
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		else{
			let alertController = UIAlertController(title: nil, message: "You must fill in the class name", preferredStyle: .Alert)
			
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	
	}

	@IBAction func unwindToMasterViewController(segue: UIStoryboardSegue) {
		print("unwinding to master view")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		print("Seguing with \(segue.description)")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	

}
