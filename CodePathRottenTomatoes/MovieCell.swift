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

        // CRASH OCCURS HERE
        posterImageView.setImageWithURL(imageUrl, placeholderImage: placeholder)

        synopsisLabel.text = withSynopsis
    }
}