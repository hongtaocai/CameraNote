//
//  LandscapeUIImagePickerController.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/2/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit

class LandscapeUIImagePickerController: UIImagePickerController {
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue);
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
