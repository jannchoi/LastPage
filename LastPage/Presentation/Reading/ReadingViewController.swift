//
//  ReadingViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//
import UIKit
import Combine
import SnapKit
import Kingfisher

final class ReadingViewController: BaseViewController {
    weak var coordinator: ReadingCoordinator?
    var viewModel: ReadingViewModel
    private var cancellables: Set<AnyCancellable> = []
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
        button.setTitle(TextResource.ButtonTitle.edit.text, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "인간 실격"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let authorLabel: UILabel = {
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
        let items = [TextResource.ReadingStatus.before.text, TextResource.ReadingStatus.inProgress.text, TextResource.ReadingStatus.after.text]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 1 // Default to "읽는 중"
        return segmentControl
    }()
    
    // memoEdit button
    private let memoEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.edit.text, for: .normal)
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
    init(viewModel: ReadingViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        coordinator?.popVC()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActions()
        bind()
        // Set initial view based on default segment
        updateContentForSelectedSegment()
    }
    override func bind() {
        viewModel.$bookDetail.sink {[weak self] bookEntity in
            guard let self = self, let bookEntity = bookEntity else {return}
            self.setupUI(item: bookEntity)
        }.store(in: &cancellables)
    }
    func setupUI(item: BookEntity) {
        let url = URL(string: item.imagePath)
        bookCoverImageView.kf.setImage(with: url,placeholder: UIImage(systemName: "person"))
        titleLabel.text = item.title
        authorLabel.text = item.author
        statusLabel.text = item.status.rawValue
        beforeReadingView.updateMemo(item: item.beforeMemo)
        afterReadingView.updateMemo(item: item.afterMemo)
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
    private func updateContentForSelectedSegment() {
        // Hide all views first
        beforeReadingView.isHidden = true
        readingInProgressView.isHidden = true
        afterReadingView.isHidden = true
        
        // Show the appropriate view based on selected segment
        switch readingStatusSegmentControl.selectedSegmentIndex {
        case 0: // 읽기 전
            beforeReadingView.isHidden = false
            clearButtonMenu() // Clear menu
        case 1: // 읽는 중
            readingInProgressView.isHidden = false
            configureMenuForEditButton() // Set up menu in advance
        case 2: // 읽은 후
            afterReadingView.isHidden = false
            clearButtonMenu() // Clear menu
        default:
            break
        }
    }

    // Pre-configure the menu for the edit button
    private func configureMenuForEditButton() {
        let addAction = UIAction(title: "Add", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.coordinator?.showEditReadingInProgress()
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
            self?.enterDeleteMode()
        }
        
        let menu = UIMenu(title: "메뉴", children: [addAction, deleteAction])
        
        memoEditButton.showsMenuAsPrimaryAction = true
        memoEditButton.menu = menu
    }

    @objc private func infoEditButtonTapped() {
        coordinator?.showEditInfo()
    }
    private func clearButtonMenu() {
        memoEditButton.menu = nil
        memoEditButton.showsMenuAsPrimaryAction = false
    }
    @objc private func memoEditButtonTapped() {
        // Check if we're in delete mode
        if readingInProgressView.isDeleteMode {
            exitDeleteMode()
            return
        }
        
        // Get current segment index
        let currentSegmentIndex = readingStatusSegmentControl.selectedSegmentIndex
        guard let bookDetail = viewModel.bookDetail else {return}
        let bookId = bookDetail.id
        // Handle based on segment
        switch currentSegmentIndex {
        case 0:
            // Clear any menu before navigation
            clearButtonMenu()
            coordinator?.showEditReading(bookId: bookId, status: .unread)
        case 1:
            showEditMenu()
        default:
            // Clear any menu before navigation
            clearButtonMenu()
            coordinator?.showEditReading(bookId: bookId, status: .completed)
        }
    }

    // Show the edit menu
    private func showEditMenu() {
        // Create menu actions
        let addAction = UIAction(title: "Add", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.coordinator?.showEditReadingInProgress()
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
            self?.enterDeleteMode()
        }
        
        // Create and present the menu
        let menu = UIMenu(title: "메뉴", children: [addAction, deleteAction])
        
        // First set showsMenuAsPrimaryAction to true
        memoEditButton.showsMenuAsPrimaryAction = true
        // Then set the menu
        memoEditButton.menu = menu
        
        // Force present the menu programmatically on first tap
        if #available(iOS 14.0, *) {
            memoEditButton.sendActions(for: .menuActionTriggered)
        }
    }
    // Enter delete mode
    private func enterDeleteMode() {
        // Enable delete mode
        readingInProgressView.isDeleteMode = true
        
        clearButtonMenu()
           memoEditButton.setTitle("Done", for: .normal)
           
           // Refresh table view to show delete buttons
        readingInProgressView.refreshTableViewForDeleteMode()
    }

    // Exit delete mode
    private func exitDeleteMode() {
        
        // Disable delete mode
        readingInProgressView.isDeleteMode = false
        
        // Restore button appearance
        memoEditButton.setTitle("Edit", for: .normal)
        
        // Refresh table view
        readingInProgressView.refreshTableViewForDeleteMode()
    }
    @objc private func segmentControlValueChanged() {
        // Clear any menu when segment changes
        clearButtonMenu()
        
        // Reset delete mode if active
        if readingInProgressView.isDeleteMode {
            readingInProgressView.isDeleteMode = false
            memoEditButton.setTitle("Edit", for: .normal)
        }
        
        // Update UI based on selected segment
        updateContentForSelectedSegment()
    }
    // MARK: - UI Setup
    override func configureHierarchy() {
        // Add subviews
        view.addSubview(topContainerView)
        view.addSubview(bottomContainerView)
        
        topContainerView.addSubview(bookCoverImageView)
        topContainerView.addSubview(infoEditButton)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(authorLabel)
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
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(infoEditButton.snp.leading).offset(-8)
        }
        
        // Writer Label
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // Date Label
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
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
    
}
