//
//  ArticleListViewController.swift
//  
//
//  Created by 坂本 浩 on 2016/05/04.
//
//

import UIKit

class ArticleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!

    var articles: [[String: String?]] = []
    var postUrl: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        table.rowHeight = 40.0
        table.separatorInset = UIEdgeInsetsZero
        title = "新着記事"
        
        APIClient.apiRequest { response in
            self.articles = response
            self.table.reloadData()
        }
    }
    
    /// tableViewの行数を指定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        let article = articles[indexPath.row]
        
        // 投稿者イメージの生成
        do {
            let url = NSURL(string: article["profile_image_url"]!!)
            let imageData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            let img = UIImage(data: imageData)
            let imageView = table.viewWithTag(1) as! UIImageView
            imageView.image = img
        } catch {
            print("Error: can't creat image.")
        }
        
        // 投稿タイトルの生成
        let label = table.viewWithTag(2) as! UILabel
        label.text = article["title"]!
        label.lineBreakMode = .ByTruncatingTail
        
        return cell
    }
    
    /// tableViewタップ時の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let article = articles[indexPath.row]

        postUrl = NSURL(string: article["url"]!!)
        performSegueWithIdentifier("toWebView", sender: nil)
    }
    
    /// 各segueの設定
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            case "toWebView":
                let webView: WebViewController = segue.destinationViewController as! WebViewController
                webView.url = postUrl
            default:
                break
        }
    }


}
