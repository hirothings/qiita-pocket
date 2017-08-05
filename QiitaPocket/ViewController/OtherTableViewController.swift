//
//  OtherTableViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class OtherTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.view.backgroundColor = UIColor.bg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        case 0:
            let licenseVC = self.storyboard?.instantiateViewController(withIdentifier: "LicensesViewController")
            self.navigationController?.pushViewController(licenseVC!, animated: true)
        case 1:
            guard let url = URL(string: "https://github.com/hirothings/qiita-pocket") else { return }
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
