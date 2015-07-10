//
//  ImagePickerHelper.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/2/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//


import UIKit
import MobileCoreServices

class ImagePickerHelper {
    class func pickMediaFromSource<T: UIViewController where T: UIImagePickerControllerDelegate, T: UINavigationControllerDelegate>(sourceType:UIImagePickerControllerSourceType, vc: T) {
        let mediaTypes =
        UIImagePickerController.availableMediaTypesForSourceType(sourceType)!
        if UIImagePickerController.isSourceTypeAvailable(sourceType)
            && mediaTypes.count > 0 {
                let picker = UIImagePickerController()
                picker.mediaTypes = [kUTTypeImage]
                picker.delegate = vc
                picker.allowsEditing = false
                picker.sourceType = sourceType
                //picker.showsCameraControls = false
                vc.presentViewController(picker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title:"Error accessing media",
                message: "Unsupported media source.",
                preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            vc.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}