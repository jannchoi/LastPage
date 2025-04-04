//
//  HighlightTableViewCell.swift
//  LastPage
//
//  Created by 최정안 on 4/2/25.
//

import UIKit
import SnapKit

final class HighlightTableViewCell: UITableViewCell{
    private let containerView = UIView()
    private let dateIcon = UIImageView()
    private let dateLabel = UILabel()
    private let pageRangeLabel = UILabel()
    private let pagesCountLabel = UILabel()
    private let memoLabel = UILabel()
    private let editButton = UIButton()
    private let memoContainerView = UIView()
    weak var delegate: HighlightTableViewCellDelegate?
    var cellIndex : Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        styleComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        pageRangeLabel.text = nil
        pagesCountLabel.text = nil
        memoLabel.text = nil
    }
    private func configureHierarchy() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        
        containerView.addSubview(dateIcon)
        containerView.addSubview(dateLabel)
        containerView.addSubview(pageRangeLabel)
        containerView.addSubview(pagesCountLabel)
        containerView.addSubview(memoContainerView)
        
        memoContainerView.addSubview(memoLabel)
        containerView.addSubview(editButton)
    }
    
    private func styleComponents() {
        // Container styling
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 3


        
        // Date icon
        dateIcon.image = UIImage(systemName: "calendar")
        dateIcon.tintColor = .gray
        dateIcon.contentMode = .scaleAspectFit
        
        // Date label
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .darkGray
        
        // Page range label
        pageRangeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        pageRangeLabel.textColor = .darkGray
        
        // Pages count label
        pagesCountLabel.font = .systemFont(ofSize: 14, weight: .regular)
        pagesCountLabel.textColor = .gray
        pagesCountLabel.textAlignment = .right
        
        // Memo label
        memoLabel.font = .systemFont(ofSize: 14, weight: .regular)
        memoLabel.textColor = .darkGray
        memoLabel.numberOfLines = 0
        //memoContainerView
        memoContainerView.backgroundColor = .systemGray6
        memoContainerView.layer.cornerRadius = 8
        // Edit button
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .gray
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    @objc func editButtonTapped() {
        guard let index = cellIndex else {return}
        delegate?.editReadingCell(self, didSelectItemAt: index)
    }
    private func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        dateIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateIcon.snp.trailing).offset(8)
            make.centerY.equalTo(dateIcon)
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        pageRangeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(dateIcon.snp.bottom).offset(16)
        }
        
        pagesCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(pageRangeLabel)
        }
        memoContainerView.snp.makeConstraints { make in
            make.top.equalTo(pageRangeLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        memoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func configure(item: ProgressMemoEntity, index: Int) {
        dateLabel.text = item.date
        memoLabel.text = item.memo
        cellIndex = index
        pageRangeLabel.text = "Pages \(item.startPage) ~ \(item.endPage)"
        guard let st = item.startPage, let stInt = Int(st), let end = item.endPage, let endInt = Int(end) else {return}
        print(st, end)
        let pageCount = stInt - endInt + 1
        pageRangeLabel.text = "\(pageCount) pages"
        
    }
}
protocol HighlightTableViewCellDelegate: AnyObject {
    func editReadingCell(_ view: HighlightTableViewCell, didSelectItemAt index: Int)
}
