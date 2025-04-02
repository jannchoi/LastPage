//
//  HighlightTableViewCell.swift
//  LastPage
//
//  Created by 최정안 on 4/2/25.
//

import UIKit

final class HighlightTableViewCell: UITableViewCell {
    private let containerView = createHighlightContainer()
    private let pageRangeLabel = createLabel(text: "", fontWeight: .medium)
    private let dateLabel = createLabel(text: "")
    private let memoLabel = createMemoLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(pageRangeLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(memoLabel)
    }
    
    private func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        pageRangeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(pageRangeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(item: ProgressMemoEntity) {
        pageRangeLabel.text = "\(item.startPage) ~ \(item.endPage)"
        dateLabel.text = item.date.formatted()
        memoLabel.text = item.memo
    }

    private static func createHighlightContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        return view
    }
    
    private static func createLabel(text: String, fontWeight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: fontWeight)
        return label
    }
    
    private static func createMemoLabel() -> UILabel {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }
}
