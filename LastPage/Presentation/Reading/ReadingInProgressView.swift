//
//  ReadingInProgressView.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit
// MARK: - ReadingInProgressView
class ReadingInProgressView: UIScrollView {
    private let highlightContainerView = createHighlightContainer()
    private let secondHighlightContainerView = createHighlightContainer()
    
    private let pageRangeLabel = createLabel(text: "18쪽 ~ 23쪽", fontWeight: .medium)
    private let dateLabel = createLabel(text: "2025.01.01")
    private let memoLabel = createMemoLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierachy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierachy() {
        backgroundColor = .darkGray
        isScrollEnabled = true
        showsVerticalScrollIndicator = true
        
        addSubview(highlightContainerView)
        addSubview(secondHighlightContainerView)
        
        highlightContainerView.addSubview(pageRangeLabel)
        highlightContainerView.addSubview(dateLabel)
        highlightContainerView.addSubview(memoLabel)
        
    }
    
    private func configureLayout() {

        highlightContainerView.snp.makeConstraints { make in
            make.top.equalTo(contentLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(16)
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
        
        secondHighlightContainerView.snp.makeConstraints { make in
            make.top.equalTo(highlightContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(contentLayoutGuide).offset(-16)
        }

    }
    
    // UI Helper Functions
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
        label.text = " init?(coder: NSCoder) {           private func configureHierachy() {         backgroundColor = .clear         addSubview(highlightContainerView)         addSubview(editButton)         highlightContainerView.addSubview(dateLabel)         highlightContainerView.addSubview(memoLabel)      }          private func configureLayout() {         // Edit Button         editButton.snp.makeConstraints { make in             make.top.equalToSuperview().offset(8)             make.trailing.equalToSuperview().offset(-16)             make.height.equalTo(30)         }                  // Highlight Container         highlightContainerView.snp.makeConstraints { make in             make.top.equalToSuperview().offset(8)             make.leading.trailing.equalToSuperview().inset(16)             make.height.equalTo(120)             make.bottom.lessThanOrEqualToSuperview().offset(-16) // Allow scrolling if needed         }                  // Date Label         dateLabel.snp.makeConstraints { make in             make.top.trailing.equalToSuperview().inset(16)         }                  // Memo Label         memoLabel.snp.makeConstraints { make in             make.top.equalTo(dateLabel.snp.bottom).offset(8)             make.leading.trailing.equalToSuperview().inset(16)             make.bottom.lessThanOrEqualToSuperview().offset(-16)         }     } } 메모 길이에 따라 수직으로 스크롤 되도록 해줘"
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }
}
