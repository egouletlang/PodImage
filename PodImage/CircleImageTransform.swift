//
//  CircleImageTransform.swift
//  PodImage
//
//  Created by Etienne Goulet-Lang on 12/5/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

public class CircleImageTransform: BaseImageTransform {
    public convenience init (radius: CGFloat) {
        self.init()
        self.radius = radius
    }
    
    private var radius: CGFloat = 1
    
    override open func modifyKey(key: String) -> String {
        return "\(key)[\(radius)-circle]"
    }
    
    override open func transform(img: UIImage?) -> UIImage? {
        return BaseImageTransformer.circle(imageRef: img, radiusPrecentage: radius)
    }
}
