//
//  ReadingViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//
import UIKit
import SnapKit

final class ReadingViewController: BaseViewController {
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let infoEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "인간 실격"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let writerLabel: UILabel = {
        let label = UILabel()
        label.text = "다자이 오사무"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "읽는 중"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let shortMemoLabel: UILabel = {
        let label = UILabel()
        label.text = "불완전한 나는 불안과 고통을 어떻게 이해하고 극복해 나갈 수 있을까?"
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    // Bottom Gray View (Reading Status)
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    // Segment Control
    private let readingStatusSegmentControl: UISegmentedControl = {
        let items = ["읽기 전", "읽는 중", "읽은 후"]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 1 // Default to "읽는 중"
        return segmentControl
    }()
    
    // memoEdit button
    private let memoEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    // Custom views for each segment
    private let beforeReadingView = ReadingView()
    private let readingInProgressView = ReadingInProgressView()
    private let afterReadingView = ReadingView()
    
    // Container for the segment content
    private let segmentContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActions()
        
        // Set initial view based on default segment
        updateContentForSelectedSegment()
    }
    
    // MARK: - UI Setup
    override func configureHierarchy() {
        // Add subviews
        view.addSubview(topContainerView)
        view.addSubview(bottomContainerView)
        
        topContainerView.addSubview(bookCoverImageView)
        topContainerView.addSubview(infoEditButton)
        topContainerView.addSubview(authorLabel)
        topContainerView.addSubview(writerLabel)
        topContainerView.addSubview(statusLabel)
        topContainerView.addSubview(shortMemoLabel)
        
        bottomContainerView.addSubview(memoEditButton)
        bottomContainerView.addSubview(readingStatusSegmentControl)
        bottomContainerView.addSubview(segmentContentView)
        

        segmentContentView.addSubview(beforeReadingView)
        segmentContentView.addSubview(readingInProgressView)
        segmentContentView.addSubview(afterReadingView)
        


    }
    
    // MARK: - Constraints
    override func configureLayout() {
        
        // Top Gray View
        topContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Book Cover
        bookCoverImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(120)
            make.height.equalTo(150)
        }
        
        // Edit Button
        infoEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // Author Label
        authorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(infoEditButton.snp.leading).offset(-8)
        }
        
        // Writer Label
        writerLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // Date Label
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(writerLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // Questions Label
        shortMemoLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
        
        // Bottom Gray View
        bottomContainerView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        //memoEdit Button
        memoEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.width.equalTo(42)
            make.height.equalTo(40)
        }
        // Segment Control
        readingStatusSegmentControl.snp.makeConstraints { make in
            make.centerY.equalTo(memoEditButton)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(memoEditButton.snp.leading)
            make.height.equalTo(40)
        }
        
        // Segment Content View
        segmentContentView.snp.makeConstraints { make in
            make.top.equalTo(readingStatusSegmentControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
        

        let customViews = [beforeReadingView, readingInProgressView, afterReadingView]
        
        for customView in customViews {
            customView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    // MARK: - Actions
    private func setupActions() {
        readingStatusSegmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        infoEditButton.addTarget(self, action: #selector(infoEditButtonTapped), for: .touchUpInside)
        memoEditButton.addTarget(self, action: #selector(memoEditButtonTapped), for: .touchUpInside)
        
    }
    override func configureView() {
        beforeReadingView.isHidden = true
        readingInProgressView.isHidden = true
        afterReadingView.isHidden = true
    }
    @objc private func segmentControlValueChanged() {
        updateContentForSelectedSegment()
    }
    
    private func updateContentForSelectedSegment() {
        // Hide all views first
        beforeReadingView.isHidden = true
        readingInProgressView.isHidden = true
        afterReadingView.isHidden = true
        
        // Show the appropriate view based on selected segment
        switch readingStatusSegmentControl.selectedSegmentIndex {
        case 0: // 읽기 전
            beforeReadingView.isHidden = false
        case 1: // 읽는 중
            readingInProgressView.isHidden = false
        case 2: // 읽은 후
            afterReadingView.isHidden = false
        default:
            break
        }
    }
    
    @objc private func infoEditButtonTapped() {
        let vc = EditInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func memoEditButtonTapped() {
        var vc: UIViewController
        switch readingStatusSegmentControl.selectedSegmentIndex {
        case 0 : vc = EditReadingViewController()
        case 1: vc = EditReadingInProgressViewController()
        default : vc = EditReadingViewController()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ReadingViewController {
    private class ReadingView: UIScrollView {
        private let highlightContainerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            view.layer.cornerRadius = 8
            return view
        }()
        
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.text = "2025.01.01"
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .right
            return label
        }()
        
        private let memoLabel: UILabel = {
            let label = UILabel()
            label.text = "class BeforeReadingView: UIScrollView {     private let highlightContainerView: UIView = {         let view = UIView()         view.backgroundColor = .systemBlue.withAlphaComponent(0.2)         view.layer.cornerRadius = 8         return view     }()          private let editButton: UIButton = {         let button = UIButton(type: .system)         button.setTitle(, for: .normal)         button.setTitleColor(.blue, for: .normal)         return button     }()          private let dateLabel: UILabel = {         let label = UILabel()         label.text =          label.font = .systemFont(ofSize: 14)         label.textAlignment = .right         return label     }()          private let memoLabel: UILabel = {         let label = UILabel()         label.text = label.font = .systemFont(ofSize: 14)         label.numberOfLines = 0         return label     }()     override init(frame: CGRect) {         super.init(frame: frame)         configureHierachy()         configureLayout()     }          @available(*, unavailable)     required init?(coder: NSCoder) {           private func configureHierachy() {         backgroundColor = .clear         addSubview(highlightContainerView)         addSubview(editButton)         highlightContainerView.addSubview(dateLabel)         highlightContainerView.addSubview(memoLabel)      }          private func configureLayout() {         // Edit Button         editButton.snp.makeConstraints { make in             make.top.equalToSuperview().offset(8)             make.trailing.equalToSuperview().offset(-16)             make.height.equalTo(30)         }                  // Highlight Container         highlightContainerView.snp.makeConstraints { make in             make.top.equalToSuperview().offset(8)             make.leading.trailing.equalToSuperview().inset(16)             make.height.equalTo(120)             make.bottom.lessThanOrEqualToSuperview().offset(-16) // Allow scrolling if needed         }                  // Date Label         dateLabel.snp.makeConstraints { make in             make.top.trailing.equalToSuperview().inset(16)         }                  // Memo Label         memoLabel.snp.makeConstraints { make in             make.top.equalTo(dateLabel.snp.bottom).offset(8)             make.leading.trailing.equalToSuperview().inset(16)             make.bottom.lessThanOrEqualToSuperview().offset(-16)         }     } } 메모 길이에 따라 수직으로 스크롤 되도록 해줘"
            label.font = .systemFont(ofSize: 14)
            label.numberOfLines = 0
            return label
        }()

        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureView()
            configureHierachy()
            configureLayout()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        private func configureView() {
            backgroundColor = .darkGray
            isScrollEnabled = true
        }
        private func configureHierachy() {
            
            
            addSubview(highlightContainerView)
            
            highlightContainerView.addSubview(dateLabel)
            highlightContainerView.addSubview(memoLabel)
        }
        
        private func configureLayout() {

            highlightContainerView.snp.makeConstraints { make in
                make.top.equalTo(contentLayoutGuide).offset(8)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(16)
                make.bottom.equalTo(contentLayoutGuide).offset(-16)
            }
            
            dateLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
            
            memoLabel.snp.makeConstraints { make in
                make.top.equalTo(dateLabel.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().offset(-16)
            }
        }
    }

}
extension ReadingViewController {
    private class ReadingInProgressView: UIScrollView {
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

}
