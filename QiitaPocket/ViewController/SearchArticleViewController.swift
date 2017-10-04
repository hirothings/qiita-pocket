//
//  SearchArticleViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/11.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchArticleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchHistoryCellDelegate {
    
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    @IBOutlet weak var searchPeriodSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchPeriodStackView: UIStackView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchPeriodTopMargin: NSLayoutConstraint!
    
    var didSelectSearchHistory = PublishSubject<String>()
    
    private let bag = DisposeBag()
    private let searchHistory = SearchHistory()
    
    private var searchType: SearchType {
        return UserSettings.getSearchType()
    }
    private var searchPeriod: SearchPeriod {
        return UserSettings.getSearchPeriod()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSegmentValue()
        configureSearchTypeSegment()
        configureSearchPeriodSegment()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidLayoutSubviews() {
        let tablecellHeight: CGFloat = 44.0
        // tableView分の高さを追加する
        contentViewHeight.constant = tablecellHeight * CGFloat(searchHistory.tags.count)
    }
    
    
    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryTableViewCell", for: indexPath) as! SearchHistoryTableViewCell
        cell.titleLabel.text = searchHistory.tags[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = searchHistory.tags[indexPath.row]
        didSelectSearchHistory.onNext(history)
    }
    
    
    // MARK: - Private Method
    
    func initSegmentValue() {
        switch searchType {
        case .rank:
            searchTypeSegment.selectedSegmentIndex = 0
        case .recent:
            searchTypeSegment.selectedSegmentIndex = 1
        }
        
        switch searchPeriod {
        case .week:
            searchPeriodSegment.selectedSegmentIndex = 0
        case .month:
            searchPeriodSegment.selectedSegmentIndex = 1
        }
    }
    
    func configureSearchTypeSegment() {
        searchTypeSegment.rx.value
            .subscribe(onNext: { [weak self] index in
                switch index {
                case 0:
                    UserSettings.setSearchType(SearchType.rank)
                    self?.searchPeriodStackView.isHidden = false
                    self?.searchPeriodTopMargin.priority = UILayoutPriority.defaultHigh
                case 1:
                    UserSettings.setSearchType(SearchType.recent)
                    self?.searchPeriodStackView.isHidden = true
                    self?.searchPeriodTopMargin.priority = UILayoutPriority.defaultLow
                default:
                    break
                }
            })
            .addDisposableTo(bag)
    }
    
    func configureSearchPeriodSegment() {
        searchPeriodSegment.rx.value
            .subscribe(onNext: { index in
                switch index {
                case 0:
                    UserSettings.setSearchPeriod(SearchPeriod.week)
                case 1:
                    UserSettings.setSearchPeriod(SearchPeriod.month)
                default:
                    break
                }
            })
            .disposed(by: bag)
    }
    
    
    // MARK: - SearchHistoryCellDelegate
    
    func didTapDeleteBtn(on cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        searchHistory.delete(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
