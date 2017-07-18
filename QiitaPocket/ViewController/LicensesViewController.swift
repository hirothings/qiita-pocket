//
//  LicensesViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/08.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class LicensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let license = License()
    var titles: [String] {
        return license?.titles ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Acknowledgements"
        self.tableView.backgroundColor = UIColor.bg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")!
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title: String = titles[indexPath.row]
        guard let licenseDetailVC = LicenseDetailViewController(title: title) else {
            return
        }
        self.navigationController?.pushViewController(licenseDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
