import UIKit


class PostFeedViewController: UITableViewController {
    
    private var feed = Feed()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "feed-logo"))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        self.tableView.register(UINib(nibName: "PostFeedCell", bundle: nil), forCellReuseIdentifier: "Post cell")
        self.tableView.estimatedRowHeight = 503
        
        let refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(refreshFeedPosts), for: UIControl.Event.valueChanged)
        refreshControl.layer.zPosition = -1
        self.refreshControl = refreshControl
        
        self.refreshFeedPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(feedHasBeenUpdated), name: Notification.Name.NewPostNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(feedHasBeenUpdated), name: Notification.Name.PostDeletedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(feedHasBeenUpdated), name: Notification.Name.FeedUpdatedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func refreshFeedPosts() {
        ServerAPI.shared.getFeedPosts(feed: self.feed) { (posts: [Post]?, error: Error?) in
            self.refreshControl!.endRefreshing()
            if posts != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func feedHasBeenUpdated(notification: NSNotification) {
        self.refreshFeedPosts()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feed.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "Post cell", for: indexPath) as! PostFeedCell
        postCell.setPost(self.feed.posts[indexPath.row])
        postCell.viewController = self
        return postCell
    }
}
