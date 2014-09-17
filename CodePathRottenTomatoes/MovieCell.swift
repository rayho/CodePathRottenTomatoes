//
//  MovieCell.swift
//  Rotten Tomatoes
//
//  Created by Ray Ho on 9/11/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!

    func populate(title: String, withImageUrlString: String, withSynopsis: String) {
        NSLog("title = %@, url = %@", title, withImageUrlString)
        titleLabel.text = title
        var imageUrl: NSURL = NSURL.URLWithString(withImageUrlString)
        var placeholder: UIImage = UIImage(named: "poster_placeholder")
        var imageUrlRequest: NSURLRequest = NSURLRequest(URL: imageUrl)

        // Set image, crossfading between placeholder and actual image
        posterImageView.setImageWithURLRequest(imageUrlRequest, placeholderImage: placeholder, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
            UIView.transitionWithView(self.posterImageView, duration: 0.33, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.posterImageView.image = image
                }, completion: nil)
        }, failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) in
            NSLog("Image download failed: %@", request.URL)
        })

        synopsisLabel.text = withSynopsis
    }
}