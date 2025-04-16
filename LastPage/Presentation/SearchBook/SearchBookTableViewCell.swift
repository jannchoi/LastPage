//
//  SearchBookTableViewCell.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit
import Kingfisher

final class SearchBookTableViewCell: UITableViewCell {
    // UI Components
    private let highlightContainerView = UIView()
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .mainText
        return label
    }()
    
    private let tagContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let firstTagView: UIView = {
        let view = UIView()
        view.backgroundColor = .tagBackground
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.tagBorder.cgColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let firstTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .mainText
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //highlightContainerView.silverFrame()
        firstTagView.layer.cornerRadius = firstTagView.frame.height / 2
    }
    func configure(item: BookDetail) {
        titleLabel.text = item.title
        authorLabel.text = item.author
        let categoryFirst = item.categoryName.first ?? ""
        firstTagLabel.text = categoryFirst

        // Load book cover
        let url = URL(string: item.cover)
        bookCoverImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "book"))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        firstTagLabel.text = nil

        bookCoverImageView.image = nil
    }
    
    private func configureView() {
        contentView.backgroundColor = .backgroundBase
        selectionStyle = .none
        addSubview(highlightContainerView)
        // Add subviews
        highlightContainerView.addSubview(bookCoverImageView)
        highlightContainerView.addSubview(titleLabel)
        highlightContainerView.addSubview(authorLabel)
        highlightContainerView.addSubview(tagContainerView)
        
        // Configure tag views
        firstTagView.addSubview(firstTagLabel)
        tagContainerView.addArrangedSubview(firstTagView)

        highlightContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // Layout constraints
        bookCoverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(80)
            make.height.equalTo(90)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookCoverImageView.snp.top)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        tagContainerView.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
        }
        
        firstTagView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        firstTagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        highlightContainerView.backgroundColor = .white
        highlightContainerView.makeShadow()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
