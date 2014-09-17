//
//  DetailController.swift
//  Rotten Tomatoes
//
//  Created by Ray Ho on 9/15/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class DetailController: UIViewController, UITextViewDelegate {
    var movie: NSDictionary?

    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var synopsisTextView: UILabel!
    @IBOutlet weak var tintView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateTintPosition()
    }

    func updateUI() {
        if (movie != nil) {
            let title: NSString = movie!.objectForKey("title") as NSString
            let posters: NSDictionary = movie!.objectForKey("posters") as NSDictionary
            let posterThumbnailUrlString: NSString = posters.objectForKey("thumbnail") as NSString
            let posterOriginalUrlString: NSString = posterThumbnailUrlString.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_org.jpg")
            let posterThumbnailUrl: NSURL = NSURL.URLWithString(posterThumbnailUrlString)
            let posterOriginalUrl: NSURL = NSURL.URLWithString(posterOriginalUrlString)
            let synopsis: NSString = movie!.valueForKey("synopsis") as NSString
            navigation.title = title
            synopsisTextView.text = synopsis
            synopsisTextView.sizeToFit()
            let contentHeight = synopsisTextView.frame.height + synopsisTextView.frame.minX + 16
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)

            // Set poster
            NSLog("Downloading original: %@", posterOriginalUrl)
            self.posterImageView.setImageWithURL(posterOriginalUrl)
        }
        updateTintPosition()
    }

    func updateTintPosition() {
        let x = 0 as CGFloat
        let y = -scrollView.contentOffset.y
        let width = tintView.frame.width
        let height = tintView.frame.maxY - y
        tintView.frame = CGRectMake(x, y, width, height)
    }
}
