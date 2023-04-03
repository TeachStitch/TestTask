//
//  QuoteTableViewCell.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import UIKit

protocol QuoteViewModelProvider {
    var name: String { get }
    var value: String { get }
    var currencyCode: String { get }
    var percentColor: VariationColor { get }
    var lastPercentUpdate: String { get }
    var isFavourite: Bool { get }
}

final class QuoteTableViewCell: UITableViewCell {
    private enum Constants {
        static let borderWidth = 2.0
        static let spacing = 4.0
        
        enum Layout {
            static let lastPercentUpdateLabel = 16.0
            static let favouriteImageViewRightIndent = 8.0
            static let leftStackViewInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        }
    }
    
    // MARK: - UI Element(s)
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            valueLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var lastPercentUpdateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var favouriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    // MARK: - Method(s)
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
        lastPercentUpdateLabel.text = nil
        favouriteImageView.image = nil
    }
    
    func configure(with model: some QuoteViewModelProvider) {
        nameLabel.text = model.name
        valueLabel.text = model.value + " " + model.currencyCode
        lastPercentUpdateLabel.text = model.lastPercentUpdate
        lastPercentUpdateLabel.textColor = model.percentColor.color
        favouriteImageView.image = model.isFavourite ? UIImage(named: "favorite") : UIImage(named: "no-favorite")
    }
}

// MARK: - Private Method(s)
private extension QuoteTableViewCell {
    func setUp() {
        let selectionView = UIView()
        selectionView.layer.borderColor = UIColor.blue.cgColor
        selectionView.layer.borderWidth = Constants.borderWidth
        selectedBackgroundView = selectionView
        
        setUpSubviews()
        setUpAutoLayoutConstraints()
    }
    
    func setUpSubviews() {
        contentView.addSubview(leftStackView)
        contentView.addSubview(lastPercentUpdateLabel)
        contentView.addSubview(favouriteImageView)
    }
    
    private func setUpAutoLayoutConstraints() {
        NSLayoutConstraint.activate([
            leftStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.leftStackViewInsets.top),
            leftStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.leftStackViewInsets.bottom),
            leftStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.leftStackViewInsets.left),
            leftStackView.trailingAnchor.constraint(equalTo: lastPercentUpdateLabel.leadingAnchor, constant: -Constants.Layout.leftStackViewInsets.right),
            
            lastPercentUpdateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lastPercentUpdateLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            lastPercentUpdateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            lastPercentUpdateLabel.trailingAnchor.constraint(equalTo: favouriteImageView.leadingAnchor, constant: -Constants.Layout.lastPercentUpdateLabel),
            
            favouriteImageView.centerYAnchor.constraint(equalTo: lastPercentUpdateLabel.centerYAnchor),
            favouriteImageView.topAnchor.constraint(equalTo: lastPercentUpdateLabel.topAnchor),
            favouriteImageView.bottomAnchor.constraint(equalTo: lastPercentUpdateLabel.bottomAnchor),
            favouriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.favouriteImageViewRightIndent),
        ])
    }
}
