//
//  ArchiveTableViewCell.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ArchiveTableViewCell: UITableViewCell {
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
        return view
    }()
    
    private let firstTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .mainText
        return label
    }()
    
    private let secondTagView: UIView = {
        let view = UIView()
        view.backgroundColor = .tagBackground
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.tagBorder.cgColor
        return view
    }()
    
    private let secondTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .mainText
        return label
    }()
    
    private let statusContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    
    func configure(item: HomeBookEntity) {
        titleLabel.text = item.bookDetail.title
        authorLabel.text = item.bookDetail.author
        configureStatusView(status: item.bookDetail.status)
        setTags(elements: item.bookDetail.categories)
        let imgPath = item.bookDetail.imagePath ?? TextResource.Global.empty.text
        ImageFormatter.shared.setImage(target: bookCoverImageView, path: imgPath)
    }
    func setTags(elements: [String]) {
        // 태그 컨테이너 초기화
        tagContainerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 태그가 없는 경우 태그 컨테이너를 숨김
        if elements.isEmpty {
            tagContainerView.isHidden = true
            return
        }
        
        tagContainerView.isHidden = false
        
        // 첫 번째 태그 추가
        firstTagView.addSubview(firstTagLabel)
        firstTagLabel.text = elements[0]
        tagContainerView.addArrangedSubview(firstTagView)
        
        firstTagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        // 태그가 2개 이상인 경우 두 번째 태그 추가
        if elements.count > 1 {
            secondTagView.addSubview(secondTagLabel)
            secondTagLabel.text = elements[1]
            tagContainerView.addArrangedSubview(secondTagView)
            
            secondTagLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.equalToSuperview().offset(12)
                make.trailing.equalToSuperview().offset(-12)
            }
        }
    }
    
    private func configureStatusView(status: ReadingStatusEntity) {
        statusLabel.text = status.rawValue
        switch status {
        case .unread:
            statusContainerView.layer.borderColor = UIColor.burgundy.cgColor
            statusLabel.textColor = .burgundy
            statusIcon.image = UIImage(systemName: "bookmark.fill")
            statusIcon.tintColor = .burgundy
        case .reading:
            statusContainerView.layer.borderColor = UIColor.mustard.cgColor
            statusLabel.textColor = .mustard
            statusIcon.image = UIImage(systemName: "book.fill")
            statusIcon.tintColor = .mustard
        case .completed:
            statusContainerView.layer.borderColor = UIColor.oliveGreen.cgColor
            statusLabel.textColor = .oliveGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .oliveGreen
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        firstTagLabel.text = nil
        secondTagLabel.text = nil
        statusLabel.text = nil
        bookCoverImageView.image = nil
        statusContainerView.isHidden = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //highlightContainerView.silverFrame()
        [firstTagView, secondTagView, statusContainerView].forEach{
            $0.layer.cornerRadius = $0.frame.height / 2
        }
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
        highlightContainerView.addSubview(statusContainerView)
        
        // Configure tag views
        firstTagView.addSubview(firstTagLabel)
        secondTagView.addSubview(secondTagLabel)
        tagContainerView.addArrangedSubview(firstTagView)
        tagContainerView.addArrangedSubview(secondTagView)
        
        // Configure status view
        statusContainerView.addSubview(statusIcon)
        statusContainerView.addSubview(statusLabel)
        
        highlightContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // Layout constraints
        bookCoverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.height.equalTo(100)
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
            make.top.equalTo(authorLabel.snp.bottom).offset(4)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
        }
        
        firstTagView.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        
        firstTagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        secondTagView.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        
        secondTagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        statusContainerView.snp.makeConstraints { make in
            make.top.equalTo(tagContainerView.snp.bottom).offset(4)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.height.equalTo(25)
            make.bottom.equalTo(bookCoverImageView.snp.bottom)
        }
        
        statusIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusIcon.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        highlightContainerView.backgroundColor = .white
        highlightContainerView.makeShadow()


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
