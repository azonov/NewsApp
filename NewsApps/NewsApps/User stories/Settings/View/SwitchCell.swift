//
//  SwitchCell.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    var actionClosure: ((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        actionClosure?(sender.isOn)
    }
}
