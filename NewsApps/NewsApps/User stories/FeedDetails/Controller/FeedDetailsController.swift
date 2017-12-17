//
//  FeedDetailsController.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import UIKit

class FeedDetailsController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var feedItem: FeedItemMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = feedItem?.content?.uppercased()
        textView.textContainerInset = UIEdgeInsets(top: 20,
                                                   left: 10,
                                                   bottom: 20,
                                                   right: 10)
    }
}
