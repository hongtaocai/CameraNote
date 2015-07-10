//
//  PictureEditingController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/2/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit

class PictureEditingController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var imageView: UIImageView!
    
    var image: UIImage?
    
    @IBOutlet var smearView: UIDrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "111"
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //imageView.image = image
        if (image != nil) {
            self.imageView.image = image
        }
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
    }
    
    @IBAction func shootPicture(sender: UIBarButtonItem) {
        ImagePickerHelper.pickMediaFromSource(UIImagePickerControllerSourceType.Camera, vc: self)
    }
    
    @IBAction func selectExistingPicture(sender: UIBarButtonItem) {
        ImagePickerHelper.pickMediaFromSource(UIImagePickerControllerSourceType.PhotoLibrary, vc: self)
    }
    
    @IBAction func smearCompleted(sender: UIBarButtonItem) {
        println("Hello")
        var cropped = smearView.getSmearedPart(imageView)
        println(cropped)
        
        
        let url = NSURL(string: "http://hongtao.cai.loves.sixin.li:6501")
        
        var err:NSError?
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        request.HTTPShouldHandleCookies = false
        
        let boundary = "---------------------------14737809831466499882746641449"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(cropped, 0.0)
        
        var body = NSMutableData()
        if (imageData != nil) {
            body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData("Content-Disposition: form-data; name=\"image\"; filename=\"crop.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            body.appendData(imageData)
            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        }
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        request.HTTPBody = body
        let postLength = "\(body.length)"
        
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response:NSURLResponse!,
            error: NSError!) -> Void in
            
            
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(response);
            println(str);
            
            if let nav = self.navigationController? {
                dispatch_async(dispatch_get_main_queue()) {
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let vc = storyboard.instantiateViewControllerWithIdentifier("TextRecognitionController") as TextRecognitionController
                    vc.textStr = str
                    nav.pushViewController(vc, animated: true )
                }
            }
        })
        
        dataTask.resume()
    }
    
    func imagePickerController(
        picker: UIImagePickerController!,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        println("imagePicker")
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
}
