//
//  ListController.swift
//  Rotten Tomatoes
//
//  Created by Ray Ho on 9/10/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Rotten Tomatoes API key
    let RT_API_KEY = "xznfv6xvh3bn9cvm99c7nvst"

    // Network error UI states
    let NETWORK_ERR_STATE_HIDDEN = 0
    let NETWORK_ERR_STATE_SHOWN = 1

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!

    // Backing movie data to be displayed in table view
    var movies: NSArray = NSArray()

    // The currently selected/tapped movie
    var movieSelected: NSDictionary?

    // Pull-to-refresh
    var refreshControl: UIRefreshControl!

    // The current network error UI state
    var networkErrorAnimationState: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize table view
        var nib = UINib(nibName: "MovieCell", bundle: nil)
        moviesTableView.registerNib(nib, forCellReuseIdentifier: "MovieCell")
        moviesTableView.dataSource = self
        moviesTableView.delegate = self

        // Initialize pull-to-refresh behavior
        refreshControl = UIRefreshControl();
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        networkErrorAnimationState = NETWORK_ERR_STATE_HIDDEN
        moviesTableView.addSubview(refreshControl)
        moviesTableView.hidden = true
        getMovies(true)
    }

    override func viewDidDisappear(animated: Bool) {
        // Deselect cell upon leaving
        var indexPath: NSIndexPath? = moviesTableView.indexPathForSelectedRow()
        if (indexPath != nil) {
            moviesTableView.deselectRowAtIndexPath(indexPath!, animated: false)
        }
    }

    func pullToRefresh() {
        getMovies(false)
    }

    func getMovies(showHUD: Bool) {
        if (showHUD) {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        hideNetworkError()
        let request = NSMutableURLRequest(URL: NSURL.URLWithString("http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=\(RT_API_KEY)"))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) in
            // Hide progress views
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.refreshControl.endRefreshing()
            self.moviesTableView.hidden = false

            // Did network request go through?
            var isSuccessful: Bool = (error == nil)
            if (!isSuccessful) {
                self.showNetworkError()
                return
            }

            // Parse response
            var errorValue: NSError? = nil
            let parsedResult: AnyObject? = (data != nil) ? NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue) : nil
            if (parsedResult != nil) {
                let dictionary: NSDictionary = parsedResult! as NSDictionary
                var movies: AnyObject? = dictionary.objectForKey("movies")
                if (movies != nil) {
                    self.movies = movies as NSArray
                    isSuccessful = true
                }
            }

            // Update UI
            if (isSuccessful) {
                self.moviesTableView.reloadData()
            } else {
                self.showNetworkError()
                return
            }
        })
    }

    func showNetworkError() {
        if (networkErrorAnimationState == NETWORK_ERR_STATE_SHOWN) {
            return
        }
        networkErrorAnimationState = NETWORK_ERR_STATE_SHOWN
        UIView.animateWithDuration(0.5, animations: {
            self.networkErrorLabel.frame = CGRectMake(0, 64, self.networkErrorLabel.frame.size.width, self.networkErrorLabel.frame.size.height)
        })
    }

    func hideNetworkError() {
        if (networkErrorAnimationState == NETWORK_ERR_STATE_HIDDEN) {
            return
        }
        networkErrorAnimationState = NETWORK_ERR_STATE_HIDDEN
        UIView.animateWithDuration(0.5, animations: {
            self.networkErrorLabel.frame = CGRectMake(0, (64 - self.networkErrorLabel.frame.size.height), self.networkErrorLabel.frame.size.width, self.networkErrorLabel.frame.size.height)
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MovieCell = moviesTableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell
        let movie: NSDictionary = movies.objectAtIndex(indexPath.row) as NSDictionary
        let title: NSString = movie.objectForKey("title") as NSString
        let posters: NSDictionary = movie.objectForKey("posters") as NSDictionary
        let posterThumbnailUrl: NSString = posters.objectForKey("thumbnail") as NSString
        let synopsis: NSString = movie.objectForKey("synopsis") as NSString
        cell.populate(title, withImageUrlString: posterThumbnailUrl, withSynopsis: synopsis)
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        movieSelected = movies[indexPath.row] as NSDictionary
        performSegueWithIdentifier("toDetailSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass movie details to the next view controller
        if (segue.identifier == "toDetailSegue") {
            var detailController: DetailController = segue.destinationViewController as DetailController
            detailController.movie = movieSelected
        }
    }
}
