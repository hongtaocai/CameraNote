//
//  ViewController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 12/29/14.
//  Copyright (c) 2014 Hongtao Cai. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonAccount: UIButton!
    
    @IBOutlet weak var buttonTakePhoto: UIButton!
    @IBOutlet weak var buttonSelectExistingPhoto: UIButton!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        showViewsByIsAuth()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        showViewsByIsAuth()
    }
    
    @IBAction func selectExistingPicture(sender: UIButton) {
        ImagePickerHelper.pickMediaFromSource(UIImagePickerControllerSourceType.PhotoLibrary, vc: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showViewsByIsAuth() {
        let isAuth : Bool = ENSession.sharedSession().isAuthenticated
        buttonLogin.hidden = isAuth
        buttonAccount.hidden = !isAuth
        buttonTakePhoto.hidden = !isAuth
        buttonSelectExistingPhoto.hidden = !isAuth
    }
    
    @IBAction func loginWithEvernote(sender: AnyObject) {
        if(!ENSession.sharedSession().isAuthenticated) {
            ENSession.sharedSession().authenticateWithViewController(self, preferRegistration: false, completion: { error in
                if (error != nil) {
                    println(error)
                }
                self.showViewsByIsAuth()
            })
        }
    }
    
    func imagePickerController(
            picker: UIImagePickerController!,
            didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismissViewControllerAnimated(false, completion: nil)
        if (image != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("CameraViewControllerID") as CameraViewController
            vc.imageFromGallery = image
            vc.isCameralMode = false
            vc.isFromPhotoGallery = true
            navigationController?.pushViewController(vc, animated: true )
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
}

