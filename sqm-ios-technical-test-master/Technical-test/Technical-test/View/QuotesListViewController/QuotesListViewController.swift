//
//  QuotesListViewController.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import UIKit

class QuotesListViewController: UIViewController {
    enum Section {
        case main
    }
    
    private enum Constants {
        enum Layout {
            static let tableViewInsets = UIEdgeInsets(top: 4, left: 8, bottom: .zero, right: 8)
        }
    }
    
    // MARK: - Properties
    private let dataManager: QuotesDataProviderProtocol = DataManager()
    private var market = Market()
    private var changedIndex: Int?
    
    // MARK: - UI Element(s)
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(QuoteTableViewCell.self)
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Section, Quote>(tableView: tableView) { tableView, indexPath, item in
        let cell: QuoteTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.backgroundColor = .white
        cell.configure(with: item)
        
        return cell
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        fetchQuotes()
    }
    
    // MARK: - Method(s)
    func fetchQuotes() {
        dataManager.fetchQuotes { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let quotes):
                    self.market.quotes = quotes
                    self.apply(quotes: quotes)
                case .failure(let error):
                    self.market.quotes.removeAll()
                    self.presentAlert(error: error)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension QuotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let quote = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let viewController = QuoteDetailsViewController(quote: quote)
        
        viewController.quoteFavouriteChanged = { [unowned self] quote in
            guard let index = market.quotes.firstIndex(of: quote) else { return }
            changedIndex = index
            market.quotes[index] = quote
            DispatchQueue.main.async {
                self.apply(quotes: self.market.quotes, animatingDifferences: false)
            }
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Private Method(s)
private extension QuotesListViewController {
    func setUp() {
        navigationItem.title = market.marketName
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
        
        setUpSubviews()
        setUpAutoLayoutConstraints()
    }
    
    func setUpSubviews() {
        tableView.backgroundColor = view.backgroundColor
        view.addSubview(tableView)
    }
    
    func setUpAutoLayoutConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.tableViewInsets.left),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.tableViewInsets.right),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.tableViewInsets.top),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.tableViewInsets.bottom),
        ])
    }
    
    func presentAlert(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func apply(quotes: [Quote], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Quote>()
        
        snapshot.appendSections([Section.main])
        snapshot.appendItems(quotes, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
