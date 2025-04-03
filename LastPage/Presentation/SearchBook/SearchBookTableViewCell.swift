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
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        
    }
    func configure(item: BookDetail) {
        titleLabel.text = item.title
        authorLabel.text = item.author
        let url = URL(string: item.cover)
        bookCoverImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "star"))
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        bookCoverImageView.image = nil
    }
    private func configureView() {
        contentView.addSubview(bookCoverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        
        bookCoverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
