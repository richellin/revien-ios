//
//  CustomCell.swift
//  ios
//
//  Created by sangjun_lee on 2017/04/13.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    private var hiddenFlg = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(sentence :Sentence) {
        mainLabel.text = sentence.ko
        subLabel.text = sentence.en
        hiddenFlg = false;
    }
    
    // self.subLabel.isHidden
    
    func hideShow() {
        if(hiddenFlg) {
            hiddenFlg = false
            mainLabel.isHidden = hiddenFlg
        } else {
            hiddenFlg = true
            self.mainLabel.isHidden = hiddenFlg
        }
    }
}
