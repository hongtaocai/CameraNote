//
//  UIDrawingView.swift
//  CameraNote
//
//  Created by Hongtao Cai on 1/2/15.
//  Copyright (c) 2015 Hongtao Cai. All rights reserved.
//

import UIKit
import CoreGraphics

class UIDrawingView: UIView {
    
    var lines: [UILine] = []
    var lastPoint: CGPoint!
    var viewsToHideWhenTouched: [UIView] = []
    
    let strokeWidth: CGFloat = 20.0
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastPoint = touches.anyObject()?.locationInView(self)
        for v in viewsToHideWhenTouched {
            v.hidden = true
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self)
        lines.append(UILine(start: lastPoint, end: newPoint!))
        lastPoint = newPoint
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for v in viewsToHideWhenTouched {
            v.hidden = false
        }
    }
    
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        let rect :CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
        CGContextFillRect(context, rect)
        
        CGContextBeginPath(context)
        for line in lines {
            CGContextMoveToPoint(context, line.start.x, line.start.y)
            CGContextAddLineToPoint(context, line.end.x, line.end.y)
        }
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, strokeWidth)
        
        CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextStrokePath(context)
        
//        if (lines.count == 0) {
//            return
//        }
//        let boundingBox : CGRect = findBoundingBox()
//        CGContextSetLineWidth(context, 1.0)
//        CGContextStrokeRect(context, boundingBox)
    }
    
    func findBoundingBox() -> CGRect {
        var minX = lines[0].start.x
        var minY = lines[0].start.y
        var maxX = minX
        var maxY = minY
        for line in lines {
            for point in [line.start, line.end] {
                minX = min(point.x, minX)
                maxX = max(point.x, maxX)
                minY = min(point.y, minY)
                maxY = max(point.y, maxY)
            }
        }
        minX = max(0, minX - strokeWidth/2)
        minY = max(0, minY - strokeWidth/2)
        maxX = min(self.bounds.size.width, maxX + strokeWidth/2)
        maxY = min(self.bounds.size.height, maxY + strokeWidth/2)
        return CGRectMake(minX, minY, maxX-minX, maxY-minY)
    }
    
    func clear() {
        lines = []
        lastPoint = nil
        self.setNeedsDisplay()
    }
    
    func croppImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        var img = fixOrientation(imageToCrop)
        
        println(rect)
        println(imageToCrop)
        println(img)
        //println(imageToCrop.CGImage.width)
        //println(imageToCrop.CGImage.height)
        var imageRef:CGImageRef = CGImageCreateWithImageInRect(img.CGImage, rect)
        var cropped:UIImage = UIImage(CGImage:imageRef)!
        return cropped
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if(img.imageOrientation == UIImageOrientation.Up) {
            return img
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        img.drawInRect(CGRectMake(0,0,img.size.width, img.size.height))
        var normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func imageLocationInImageView(image: UIImage, imageView: UIImageView) -> CGRect{
        var renderedWidth :CGFloat = 0
        var renderedHeight :CGFloat = 0
        let imageIsSlimmerThanView = image.size.width * imageView.bounds.size.height / image.size.height < imageView.bounds.size.width
        let imageViewIsAspectFit = (imageView.contentMode == .ScaleAspectFit)
        if ( imageIsSlimmerThanView^imageViewIsAspectFit == false) {
            // image is slimmer and aspect fit
            renderedHeight = imageView.bounds.size.height
            renderedWidth = image.size.width * renderedHeight / image.size.height
        }
        else {
            renderedWidth = imageView.bounds.size.width
            renderedHeight = renderedWidth * image.size.height / image.size.width
            println("image is fatter, \(renderedWidth), \(renderedHeight)")
        }
        return CGRectMake((imageView.bounds.size.width - renderedWidth)/2, (imageView.bounds.size.height - renderedHeight)/2, renderedWidth, renderedHeight)
    }
    
    func getSmearedPart(imageView: UIImageView) -> UIImage{
        if lines.count == 0 {
            return UIImage()
        }
        let boundingBox = findBoundingBox();
        var minX = boundingBox.origin.x
        var minY = boundingBox.origin.y
        var maxX = boundingBox.origin.x + boundingBox.width
        var maxY = boundingBox.origin.y + boundingBox.height
        
        var imageLoc = imageLocationInImageView(imageView.image!, imageView: imageView)
        
        minX = max(minX, imageLoc.origin.x)
        minY = max(minY, imageLoc.origin.y)
        maxX = min(maxX, imageLoc.origin.x + imageLoc.size.width)
        maxY = min(maxY, imageLoc.origin.y + imageLoc.size.height)
        
        println("mins and maxs: \(minX), \(maxX), \(minY), \(maxY)")
        
        minX -= imageLoc.origin.x
        maxX -= imageLoc.origin.x
        minY -= imageLoc.origin.y
        maxY -= imageLoc.origin.y
        
        println("mins and maxs: \(minX), \(maxX), \(minY), \(maxY)")
        
        var ratio = imageView.image!.size.width / imageLoc.width
        
        minX *= ratio
        minY *= ratio
        maxX *= ratio
        maxY *= ratio
        
        println("mins and maxs: \(minX), \(maxX), \(minY), \(maxY)")
        
        println("imageViewsize: \(imageView.bounds.size)")
        println("imageViewframsize: \(imageView.frame.size)")
        println("imagesize: \(imageView.image?.size)")
        println("imagesize: \(imageView.image?)")
        println("imageLocationInImageView: \(imageLoc)")
            
            
        return croppImage(imageView.image!, toRect: CGRectMake(
            minX, minY, maxX-minX, maxY-minY)
        )
    }

}
