//
//  SummaryTableViewCell.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 11/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import UIKit

class SummaryTableViewCell : UITableViewCell {
    @IBOutlet weak var placeLabel: UILabel! = nil
    @IBOutlet weak var magnitudeLabel: UILabel! = nil
    @IBOutlet weak var magnitudeContainer: UIView! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView = UIView()
        
        let mask = CALayer()
        
        mask.frame = self.bounds
        mask.contents = UIImage(named: "img_mask")!.CGImage
        self.backgroundView?.layer.mask = mask
        
        self.magnitudeContainer.layer.borderColor = UIColor.whiteColor().CGColor
        self.magnitudeContainer.layer.borderWidth = 1.0
        self.magnitudeContainer.layer.cornerRadius = 5.0
        self.magnitudeContainer.layer.masksToBounds = true
    }
    
    var viewModel: SummaryViewViewModel! {
        didSet {
            placeLabel.text = viewModel?.place
            magnitudeLabel.text = viewModel?.magnitude
            
            self.backgroundView?.backgroundColor = viewModel?.color ?? UIColor.whiteColor()
        }
    }
}