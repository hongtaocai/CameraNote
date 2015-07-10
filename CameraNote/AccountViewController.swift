//
//  AccountViewController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/6/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var buttonLogout: UIButton!
    
    @IBOutlet weak var buttonPrivacy: UIButton!
    
    func setBorderForButton(button :UIButton!) {
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBorderForButton(self.buttonLogout)
        setBorderForButton(self.buttonPrivacy)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutWithEvernote(sender: AnyObject) {
        if (ENSession.sharedSession().isAuthenticated) {
            ENSession.sharedSession().unauthenticate()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func openPrivacyTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL( NSURL(string: "http://www.google.com")! )
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
