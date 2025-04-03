//
//  ArchiveTableViewCell.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import Kingfisher

final class ArchiveTableViewCell: UITableViewCell {
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
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    private let prologueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        
    }
    func configure(item: BookEntity) {
        titleLabel.text = item.bookDetail.title
        authorLabel.text = item.bookDetail.author
        statusLabel.text = item.bookDetail.status.rawValue
        categoryLabel.text = item.bookDetail.categories.first
        prologueLabel.text = item.bookDetail.shortMemo
        let imgPath = item.bookDetail.imagePath ?? TextResource.Global.empty.text
        let url = URL(string: imgPath)
        bookCoverImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person"))
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        bookCoverImageView.image = nil
        statusLabel.text = nil
        categoryLabel.text = nil
        prologueLabel.text = nil
    }
    private func configureView() {
        contentView.addSubview(bookCoverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(prologueLabel)
        
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
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        prologueLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
