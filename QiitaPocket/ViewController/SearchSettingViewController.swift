//
//  SearchSettingViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/11.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchSettingViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var periodSegment: UISegmentedControl!
    @IBOutlet weak var searchHistoryTableView: UITableView!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSegmentValue()
        saveSearchSettings()
    }
    
    func initSegmentValue() {
        guard let sort = UserSettings.searchSort.string(), let sortType = SearchSort(rawValue: sort) else {
            return
        }
        guard let period = UserSettings.searchPeriod.string(), let periodType = SearchPeriod(rawValue: period) else {
            return
        }
        
        switch sortType {
        case .recent:
            sortSegment.selectedSegmentIndex = 0
        case .popular:
            sortSegment.selectedSegmentIndex = 1
        }
        
        switch periodType {
        case .all:
            periodSegment.selectedSegmentIndex = 0
        case .month:
            periodSegment.selectedSegmentIndex = 1
        case .week:
            periodSegment.selectedSegmentIndex = 2
        }
    }
    
    func saveSearchSettings() {
        sortSegment.rx.value
            .subscribe(onNext: { index in
                switch index {
                case 0:
                    UserSettings.searchSort.set(value: SearchSort.recent.rawValue)
                case 1:
                    UserSettings.searchSort.set(value: SearchSort.popular.rawValue)
                default:
                    break
                }
            })
            .addDisposableTo(bag)
        
        periodSegment.rx.value
            .subscribe(onNext: { index in
                switch index {
                case 0:
                    UserSettings.searchPeriod.set(value: SearchPeriod.all.rawValue)
                case 1:
                    UserSettings.searchPeriod.set(value: SearchPeriod.month.rawValue)
                case 2:
                    UserSettings.searchPeriod.set(value: SearchPeriod.week.rawValue)
                default:
                    break
                }
            })
            .addDisposableTo(bag)
    }
}
