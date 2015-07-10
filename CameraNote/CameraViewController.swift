//
//  CameraViewController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/4/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var isCameralMode : Bool = true
    var imageFromGallery : UIImage?
    var isFromPhotoGallery: Bool = false

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonShootPhoto: UIButton!
    @IBOutlet weak var buttonFinishTextSelection: UIButton!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var drawingView: UIDrawingView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var session :AVCaptureSession?
    var stillImageOutput :AVCaptureStillImageOutput?
    
    func showViewsByMode() {
        cameraView.hidden = true
        activityIndicatorView.hidden = true
        
        buttonShootPhoto.hidden = !isCameralMode
        imageView.hidden = isCameralMode
        buttonFinishTextSelection.hidden = isCameralMode
        buttonClear.hidden = isCameralMode
        drawingView.hidden = isCameralMode
    }
    
    @IBAction func finishTextSelection(sender: AnyObject) {
        
        if (!self.activityIndicatorView.isAnimating()) {
            self.activityIndicatorView.hidden = false
            self.activityIndicatorView.startAnimating()
        }
        
        self.checkInternet(false, completionHandler: {(internet:Bool) in
            
            if (!internet) {
                let actionSheetController: UIAlertController = UIAlertController(title: "No Internet Connection", message: "", preferredStyle: .Alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                }
                actionSheetController.addAction(cancelAction)
                self.presentViewController(actionSheetController, animated: true, completion: nil)
                if (self.activityIndicatorView.isAnimating()) {
                    self.activityIndicatorView.stopAnimating()
                }
                return
            }
        
            var cropped = self.drawingView.getSmearedPart(self.imageView)
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
                        vc.image = cropped
                        if (self.activityIndicatorView.isAnimating()) {
                            self.activityIndicatorView.stopAnimating()
                        }
                        nav.pushViewController(vc, animated: true )
                    }
                }
            })
            
            dataTask.resume()
        })
    }
    
    @IBAction func clear(sender: AnyObject) {
        drawingView.clear()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showViewsByMode()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        drawingView.viewsToHideWhenTouched = [buttonCancel, buttonClear, buttonFinishTextSelection]
        println("isFromPhotoGallery: \(isFromPhotoGallery)")
        if (isFromPhotoGallery) {
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.image = imageFromGallery
        } else {
            imageView.contentMode = .ScaleAspectFill
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        showViewsByMode()
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
        if (self.activityIndicatorView.isAnimating()) {
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (isCameralMode) {
            session = AVCaptureSession()
            session?.sessionPreset = AVCaptureSessionPresetPhoto
            let inputDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            var error:NSError?
            let deviceInput: AVCaptureInput? = AVCaptureDeviceInput.deviceInputWithDevice(inputDevice, error: &error) as? AVCaptureInput
            
            if (session == nil || deviceInput == nil) {
                return
            }
            
            if(session!.canAddInput(deviceInput)) {
                session!.addInput(deviceInput)
            }
            
            var previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            var rootLayer = self.view.layer
            rootLayer.masksToBounds = true
            let frame = self.cameraView.frame
            
            previewLayer.frame = frame
            rootLayer.insertSublayer(previewLayer, atIndex: 0)
            
            stillImageOutput = AVCaptureStillImageOutput()
            
            if(stillImageOutput == nil) {
                return
            }
            
            let outputSettings = NSDictionary(object: AVVideoCodecJPEG, forKey: AVVideoCodecKey)
            stillImageOutput!.outputSettings = outputSettings
            
            session?.addOutput(stillImageOutput!)
            session?.startRunning()
            println("running")
        } else {
            if (session != nil) {
                if (session!.running) {
                    session!.stopRunning();
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        var videoConnection:AVCaptureConnection?
        
        for connection in stillImageOutput!.connections {
            for port in connection.inputPorts! {
                if (port.mediaType == (AVMediaTypeVideo)) {
                    videoConnection = connection as? AVCaptureConnection
                    break
                }
            }
            if(videoConnection != nil) {
                break
            }
        }
        
        stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer : CMSampleBufferRef?, error : NSError?) -> Void in
            if( (imageDataSampleBuffer) != nil) {
                let imageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.isCameralMode = false
                    self.showViewsByMode()
                    self.imageView.image = UIImage(data: imageData)
                    self.session?.stopRunning()
                }
            }
        })
    }
    
    
    func checkInternet(flag:Bool, completionHandler:(internet:Bool) -> Void)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: "http://www.google.com/")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler:
            {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                let rsp = response as NSHTTPURLResponse?
                completionHandler(internet:rsp?.statusCode == 200)
        })
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
