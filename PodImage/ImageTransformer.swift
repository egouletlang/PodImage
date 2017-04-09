//
//  ImageTransformer.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/5/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public class BaseImageTransformer {
    
    private class func createImageRect(avail: CGRect,_ image: CGSize) -> CGRect {
        
        var retSize = image
        
        //Image Larger?
        if retSize.width > avail.width {
            retSize.height = retSize.height * (avail.width / retSize.width)
            retSize.width = avail.width
        }
        
        // Is the image still larger?
        if retSize.height > avail.height {
            retSize.width = retSize.width * (avail.height / retSize.height)
            retSize.height = avail.height
        }
        
        return CGRect(
            x: (avail.width - retSize.width) / 2 + avail.origin.x,
            y: (avail.height - retSize.height) / 2 + avail.origin.y,
            width: retSize.width,
            height: retSize.height)
        
    }
    
    
    // This method takes an image and centers it in box - with insets - and respects the image's
    // aspect ratio.
    public class func centerImage(imageRef: UIImage?, size: CGSize, insets: UIEdgeInsets) -> UIImage? {
        guard let image = imageRef else {
            return imageRef
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        image.draw(in: createImageRect(avail: UIEdgeInsetsInsetRect(rect, insets), image.size))
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret;
        
    }
    
    
    // Circle Transform
    public class func circle(imageRef: UIImage?, radiusPrecentage: CGFloat) -> UIImage? {
        guard let image = imageRef else {
            return imageRef
        }
        
        let xOffset: CGFloat = (image.size.width < image.size.height) ? (0) : (image.size.width - image.size.height) / 2
        let yOffset: CGFloat = (image.size.width < image.size.height) ? (image.size.height - image.size.width) / 2 : (0)
        let size: CGFloat = (image.size.width < image.size.height) ? (image.size.width) : (image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        let radius: CGFloat = size * radiusPrecentage / 2
        
        context?.beginPath()
        context?.addArc(center: CGPoint(x: size / 2, y: size / 2), radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        context?.closePath()
        context?.clip()
        
        let targetRect = CGRect(x: -xOffset, y: -yOffset, width: image.size.width, height: image.size.height);
        image.draw(in: targetRect)
        
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret;
        
    }
    
    
    
    // Background Transform
    public class func setBackgroundColor(imageRef: UIImage?, color: UIColor?) -> UIImage? {
        guard let image = imageRef, let c = color else {
            return imageRef
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: image.size.width, height: image.size.height), false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let targetRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height);
        
        context?.setFillColor(c.cgColor)
        context?.fill(targetRect)
        image.draw(in: targetRect)
        
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret;
    }
    
    // Mask
    public class func imageWithColorMask(imageRef: UIImage?, color: UIColor) -> UIImage? {
        guard let image = imageRef, let cgImage = image.cgImage else {
            return imageRef
        }
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -(imageRect.size.height))
        
        context?.clip(to: imageRect, mask: cgImage)
        context?.setFillColor(color.cgColor)
        context?.fill(imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // Different Orientations
    public class func flip(imageRef: UIImage?, scale: CGFloat, orientation: UIImageOrientation) -> UIImage? {
        guard let image = imageRef, let cgImage = image.cgImage else {
            return imageRef
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        
    }
    
    public class func flipHorizontally(imageRef: UIImage?) -> UIImage? {
        guard let image = imageRef else {
            return imageRef
        }
        return flip(imageRef: image, scale: 1, orientation: .upMirrored)
    }
    
    // Stretchable
    private class func suggestedEdgeInsets(size: CGSize) -> UIEdgeInsets {
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        return UIEdgeInsetsMake(center.y, center.x, center.y, center.x)
    }
    public class func strectchableImage(imageRef: UIImage?, insets: UIEdgeInsets = UIEdgeInsets.zero) -> UIImage? {
        guard let image = imageRef else {
            return imageRef
        }
        let eInsets = (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsets.zero)) ? (insets) : (suggestedEdgeInsets(size: image.size))
        return image.resizableImage(withCapInsets: eInsets, resizingMode: .stretch)
    }
    
    //Transform
    public class func rotateImage(imageRef: UIImage?, orientation: UIImageOrientation) -> UIImage? {
        guard let image = imageRef, image.cgImage != nil else {
            return imageRef
        }
        
        if (orientation == UIImageOrientation.right) {
            return rotateImage(image: image, radians: CGFloat(0.5 * Double.pi))
        } else if (orientation == UIImageOrientation.left) {
            return rotateImage(image: image, radians: -CGFloat(0.5 * Double.pi))
        } else if (orientation == UIImageOrientation.down) {
            return rotateImage(image: image, radians: CGFloat(Double.pi))
        }
        
        return image
    }
    private class func rotateImage(image: UIImage, radians: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let transform = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = transform
        
        let rotatedSize = rotatedViewBox.frame.size
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize);
        let context = UIGraphicsGetCurrentContext();
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        context?.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2);
        
        // Rotate the image context
        context?.rotate(by: radians);
        
        // Now, draw the rotated/scaled image into the context
        context?.scaleBy(x: 1.0, y: -1.0);
        
        context?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage ?? image
    }
    
    // Image from UIView
    public class func imageFromView(view: UIView?) -> UIImage? {
        guard let v = view else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(v.bounds.size, true, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            v.layer.render(in: context)
            
            let ret = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return ret;
        }
        return nil
    }
}
