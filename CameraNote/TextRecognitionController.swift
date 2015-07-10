//
//  TextRecognitionController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/3/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit

class TextRecognitionController: UIViewController {
    
    let photoMaxWidth = 500
    
    @IBOutlet weak var textView: UITextView!
    
    var textStr:String?
    
    var image: UIImage?
    
    @IBOutlet weak var originalPhoto: UIImageView!
    
    @IBOutlet weak var buttonSaveText: UIButton!
    
    @IBOutlet weak var buttonSavePhoto: UIButton!
    
    let imageTextSelected :UIImage! = UIImage(named: "text_selected.png")
    let imageTextUnselected :UIImage! = UIImage(named: "text_unselected.png")
    let imagePhotoSelected :UIImage! = UIImage(named: "photo_selected.png")
    let imagePhotoUnselected :UIImage! = UIImage(named: "photo_unselected.png")
    
    var isTextMode: Bool = true
    
    func showViewsByMode() {
        textView.hidden = !isTextMode
        originalPhoto.hidden = isTextMode
        if(isTextMode) {
            buttonSaveText.setImage(imageTextSelected, forState: .Normal)
            println(imagePhotoUnselected)
            buttonSavePhoto.setImage(imagePhotoUnselected, forState: .Normal)
        } else {
            buttonSaveText.setImage(imageTextUnselected, forState: .Normal)
            buttonSavePhoto.setImage(imagePhotoSelected, forState: .Normal)
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (textStr != nil) {
            textView.text = textStr
        }
        if (image != nil) {
            originalPhoto.image = image
        }
        isTextMode = true
        showViewsByMode()
    }
    
    @IBAction func switchToTextMode(sender: AnyObject) {
        isTextMode = true
        showViewsByMode()
    }
    
    @IBAction func switchToPhotoMode(sender: AnyObject) {
        isTextMode = false
        showViewsByMode()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (textStr != nil) {
            textView.text = textStr
        }
        if (image != nil) {
            originalPhoto.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEvernote(sender: AnyObject) {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .LongStyle
        let dateStr = formatter.stringFromDate(date)
        
        var note :ENNote = ENNote()
        note.title = "Text Note \(dateStr)"
        if (isTextMode) {
            note.content = ENNoteContent(string: textStr)
        } else {
            note.addResource(ENResource(image: image)!)
        }
        ENSession.sharedSession().uploadNote(note, notebook: nil, completion: {
            noteRef, error in
            var message:String?
            if ((noteRef) != nil) {
                message = "note created.";
            } else {
                message = "Failed to create photo note.";
            }
            println(message)
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
