//
//  imageCell.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class imageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: Photo!
}

