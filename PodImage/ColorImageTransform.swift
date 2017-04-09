//
//  ColorImageTransform.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 4/8/17.
//  Copyright © 2017 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import BaseUtils

public class ColorImageTransform: BaseImageTransform {
    public convenience init (color: String) {
        self.init()
        self.color = color
    }
    
    private var color: String?
    
    override open func modifyKey(key: String) -> String {
        return "\(key)[\(color ?? "")-circle]"
    }
    
    override open func transform(img: UIImage?) -> UIImage? {
        if let c = self.color, let clr = UIColor(hexString: c) {
            return BaseImageTransformer.imageWithColorMask(imageRef: img, color: clr)
        }
        return img
    }
}
