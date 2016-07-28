//
//  ClassCreationViewController.swift
//  crammunity
//
//  Created by Clara Hwang on 7/18/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ClassCreationViewController: UIViewController {

	@IBOutlet weak var newClassNameTextField: UITextField!
	@IBOutlet weak var createClassButton: UIButton!
	
	var classRef: FIRDatabaseReference?
	@IBAction func onCreateClassTap(sender: AnyObject) {
		
		
//TODO: add friends to class
		
		if !self.newClassNameTextField.text!.isEmpty {
			self.classRef = FirebaseHelper.createClass(self.newClassNameTextField.text!)
//			self.dismissToMasterViewController(self)
			self.performSegueWithIdentifier("ClassCreationToCrammatesAddition", sender: self)
			
		}
		else{
			let alertController = UIAlertController(title: nil, message: "You must fill in the class name", preferredStyle: .Alert)
			
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	
	}
	@IBAction func onAddCrammatesButtonTap(sender: UIButton)
	{
		
	}
	@IBAction func dismissToMasterViewController(sender: AnyObject) {
	
		print("dismissing to master view")
		self.dismissViewControllerAnimated(true, completion: nil)
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
		if segue.identifier! == "ClassCreationToCrammatesAddition"
		{
			let vc = segue.destinationViewController as! CrammateAdditionViewController
			vc.cramClass = self.classRef
		}
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	

}
