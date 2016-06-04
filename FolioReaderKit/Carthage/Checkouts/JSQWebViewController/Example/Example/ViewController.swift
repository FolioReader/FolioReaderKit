//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQWebViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQWebViewController
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

import JSQWebViewController


class ViewController: UITableViewController {

    let url = NSURL(string: "http://jessesquires.com")!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = true
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row == 2 {
            return
        }

        let webVC = WebViewController(url: url)

        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(webVC, animated: true)

        case 1:
            let nav = UINavigationController(rootViewController: webVC)
            presentViewController(nav, animated: true, completion: nil)

        default: break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let webViewController = segue.destinationViewController as? WebViewController
        webViewController?.urlRequest = NSURLRequest(URL: url)
    }
    
}

