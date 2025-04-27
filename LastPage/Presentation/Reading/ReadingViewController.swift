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
    
    // Book Detail Section
    private let bookDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .backgroundBase
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .btnTint
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .btnTint
        return button
    }()

    // Book Metadata Section
    private let metadataView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeShadow()
        return view
    }()
    
    private let dateAddedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .mainText
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .mainText
        return label
    }()
    
    // Notes Section
    private let notesCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeShadow()
        return view
    }()
    
    private let notesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let notesContentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .mainText
        label.numberOfLines = 0
        return label
    }()
    
    // Feelings Section
    private let feelingsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeShadow()
        return view
    }()
    
    private let feelingsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Feelings"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let feelingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    // Reading Status Section
    private let memoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    // Segment Control
    private let readingStatusControl: UISegmentedControl = {
        let items = [TextResource.ReadingStatus.before.text, TextResource.ReadingStatus.inProgress.text, TextResource.ReadingStatus.after.text]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 1 // Default to "읽는 중"
        return segmentControl
    }()
    // Custom views for each segment
    private let beforeReadingView = ReadingView()
    private let readingInProgressView = ReadingInProgressView()
    private let afterReadingView = ReadingView()
    // Container for the segment content
    private let segmentContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    // Reading Sessions Button - For adding new reading sessions
    private let memoEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .btnTint
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // ScrollView to contain all content
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView = UIView()
    
    // MARK: - Initialization
    
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
        setupActions()
        bind()
        updateContentForSelectedSegment()
        bookDetailView.isUserInteractionEnabled = true
        memoContainerView.isUserInteractionEnabled = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        //setMemoEditIsAvailable()
    }
//    private func setMemoEditIsAvailable() {
//        memoEditButton.isEnabled = viewModel.bookDetail?.id != nil
//    }
    // MARK: - UI Setup
    
    override func configureView() {
        view.backgroundColor = .backgroundBase
        readingInProgressView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
       
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add main sections to content view
        contentView.addSubview(bookDetailView)
        contentView.addSubview(metadataView)
        contentView.addSubview(notesCardView)
        contentView.addSubview(feelingsCardView)
        contentView.addSubview(memoContainerView)
        
        // Book detail components
        bookDetailView.addSubview(bookCoverImageView)
        bookDetailView.addSubview(titleLabel)
        bookDetailView.addSubview(authorLabel)
        bookDetailView.addSubview(editButton)
        
        // Metadata components
        metadataView.addSubview(dateAddedLabel)
        metadataView.addSubview(progressLabel)
        
        // Notes components
        notesCardView.addSubview(notesTitleLabel)
        notesCardView.addSubview(notesContentLabel)
        
        // Feelings components
        feelingsCardView.addSubview(feelingsTitleLabel)
        feelingsCardView.addSubview(feelingsStackView)
        
        // Reading status components
        memoContainerView.addSubview(memoTitleLabel)
        memoContainerView.addSubview(readingStatusControl)
        memoContainerView.addSubview(memoEditButton)
       
        // Reading status components
        memoContainerView.addSubview(readingStatusControl)
        memoContainerView.addSubview(segmentContentView)
        segmentContentView.addSubview(beforeReadingView)
        segmentContentView.addSubview(readingInProgressView)
        segmentContentView.addSubview(afterReadingView)

    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // Book detail layout
        bookDetailView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        
        bookCoverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookCoverImageView.snp.top).offset(10)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
       
        // Metadata layout
        metadataView.snp.makeConstraints { make in
            make.top.equalTo(bookDetailView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(70)
        }
        
        dateAddedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        progressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // Notes layout
        notesCardView.snp.makeConstraints { make in
            make.top.equalTo(metadataView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0)
        }
        
        notesTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        notesContentLabel.snp.makeConstraints { make in
            make.top.equalTo(notesTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        
        // Feelings layout
        feelingsCardView.snp.makeConstraints { make in
            make.top.equalTo(notesCardView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0)
        }
        
        feelingsTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        feelingsStackView.snp.makeConstraints { make in
            make.top.equalTo(feelingsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        memoEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.trailing.equalTo(feelingsCardView.snp.trailing).inset(16)
            make.leading.equalTo(contentView.snp.centerX).offset(4)
            make.height.equalTo(25)
            
        }
        memoTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalTo(feelingsTitleLabel)
            make.trailing.equalTo(contentView.snp.centerX).inset(4)
            make.centerY.equalTo(memoEditButton)
            make.height.equalTo(25)
        }

        
        // Reading status layout
        memoContainerView.snp.makeConstraints { make in
            make.top.equalTo(feelingsCardView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(500)
            make.bottom.equalToSuperview().inset(24)
        }
        
        readingStatusControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(memoEditButton.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(36)
        }
        segmentContentView.snp.makeConstraints { make in
            make.top.equalTo(readingStatusControl.snp.bottom).offset(4)
            make.height.equalTo(400)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        let customViews = [beforeReadingView, readingInProgressView, afterReadingView]
        
        for customView in customViews {
            customView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    // MARK: - Data Binding
    // Add to bind() method or create if it doesn't exist
    override func bind() {
        // Observe book details
        viewModel.$bookDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookEntity in
                guard let self = self, let bookEntity = bookEntity else { return }
                
                // Update UI with book details
                self.updateUI(with: bookEntity)
                
                // Enable memo edit button if book ID exists
                //self.setMemoEditIsAvailable()
            }
            .store(in: &cancellables)
        
        viewModel.$fetchError.compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
    }

    private func updateUI(with item: BookEntity) {
        navigationItem.title = item.bookDetail.title
        titleLabel.text = item.bookDetail.title
        authorLabel.text = item.bookDetail.author
        
        let imgPath = item.bookDetail.imagePath ?? TextResource.Global.empty.text
        ImageFormatter.shared.setImage(target: bookCoverImageView, path: imgPath)
        dateAddedLabel.text = DateFormattManager.shared.dateToStr(item.bookDetail.addedDate)
        progressLabel.text = item.bookDetail.status.rawValue
        readingInProgressView.updateData(data: item.inProgressMemo)
        beforeReadingView.updateMemo(item: item.beforeMemo)
        afterReadingView.updateMemo(item: item.afterMemo)

        updateNotesVisibility(notes: item.bookDetail.shortMemo)
        updateFeelingsVisibility(feelings: item.bookDetail.feelings)
        setupGenreLabels(genres: item.bookDetail.categories)
    }


    private func updateFeelingsVisibility(feelings: [String]) {
        if feelings.isEmpty {
            // Hide feelings view if there are no feelings
            feelingsCardView.isHidden = true
            return
        }
        
        // Show feelings view
        feelingsCardView.isHidden = false

        // Clear existing feelings
        for subview in feelingsStackView.arrangedSubviews {
            feelingsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Add feeling chips
        for feeling in feelings {
            let chipView = createChipView(with: feeling)
            feelingsStackView.addArrangedSubview(chipView)
        }
        // Calculate the proper height for the card
        let totalHeight = feelingsTitleLabel.frame.height + feelingsStackView.frame.height + 40

        // Update constraints with the proper height
        feelingsCardView.snp.updateConstraints { make in
            make.height.equalTo(max(80, totalHeight)) // 최소 높이 80으로 설정
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()

    }

    private func createChipView(with text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tagBackground
        containerView.layer.borderColor = UIColor.tagBorder.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.layer.cornerRadius = 16
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .mainText
        label.textAlignment = .center
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(15)
            make.top.bottom.equalToSuperview().inset(8)
        }
        containerView.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(21)
            }
        return containerView
    }
    
    private func updateNotesVisibility(notes: String) {
        if notes.isEmpty {
            // Hide notes view if there are no notes
            notesCardView.isHidden = true
            return
        }
        // Show notes view and update content
        notesCardView.isHidden = false
        notesContentLabel.text = notes
        
        // Update constraints to fit content
        notesContentLabel.sizeToFit()
        notesCardView.snp.updateConstraints { make in
            // Add some padding to the height
            make.height.equalTo(notesTitleLabel.frame.height + notesContentLabel.frame.height + 40)
        }
        
        // Request layout update
        view.setNeedsLayout()
    }
    private func setupGenreLabels(genres: [String]) {
        let genreStackView = UIStackView()
        genreStackView.axis = .horizontal
        genreStackView.spacing = 8
        genreStackView.distribution = .fillProportionally
        
        bookDetailView.addSubview(genreStackView)
        genreStackView.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        for genre in genres {
            let genreChip = createChipView(with: genre)
            genreStackView.addArrangedSubview(genreChip)
        }
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
        readingStatusControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        memoEditButton.addTarget(self, action: #selector(memoEditButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {

        coordinator?.showEditInfo(passedBook: viewModel.bookDetail?.bookDetail, bookId: viewModel.bookDetail?.id)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "도서 삭제",
            message: "해당 도서를 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            // Implement delete functionality
            guard let self = self, let bookId = self.viewModel.bookDetail?.id else { return }
            viewModel.deleteBook(targetId: bookId)
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
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
    private func updateContentForSelectedSegment() {
        // Hide all views first
        beforeReadingView.isHidden = true
        readingInProgressView.isHidden = true
        afterReadingView.isHidden = true
        
        // Show the appropriate view based on selected segment
        switch readingStatusControl.selectedSegmentIndex {
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
    private func clearButtonMenu() {
        memoEditButton.menu = nil
        memoEditButton.showsMenuAsPrimaryAction = false
    }
    @objc private func memoEditButtonTapped() {
        guard let bookId = viewModel.bookDetail?.id else {
            showAlert(text: "도서 저장 후 이용 가능합니다. '연필'버튼을 클릭하세요.")
            return
        }
        // 삭제 모드 체크
        if readingInProgressView.isDeleteMode {
            exitDeleteMode()
            return
        }
        
        // 현재 세그먼트 확인
        let currentSegmentIndex = readingStatusControl.selectedSegmentIndex
        
        // 세그먼트에 따른 처리
        switch currentSegmentIndex {
        case 0: // 읽기 전
            clearButtonMenu()
            coordinator?.showEditReading(bookId: bookId, status: .unread)
        case 1: // 읽는 중
            // 기존 showEditMenu() 대신 configureMenuForEditButton() 사용
            configureMenuForEditButton()
            // 메뉴 트리거
            if #available(iOS 14.0, *) {
                memoEditButton.sendActions(for: .menuActionTriggered)
            }
        case 2: // 읽은 후
            clearButtonMenu()
            coordinator?.showEditReading(bookId: bookId, status: .completed)
        default:
            break
        }
    }
    private func configureMenuForEditButton() {
        guard let bookId = viewModel.bookDetail?.id else {
                // bookId가 nil이면 메뉴를 구성하지 않음
                clearButtonMenu()
                return
            }
        let addAction = UIAction(title: "Add ", image: UIImage(systemName: "plus")) { [weak self] _ in
            let indexToAppend = (self?.viewModel.bookDetail?.inProgressMemo.count ?? 0) + 1
            
            self?.coordinator?.showEditReadingInProgress(bookId: self?.viewModel.bookId, index: indexToAppend)
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
            self?.enterDeleteMode()
        }
        
        let menu = UIMenu(title: "메뉴", children: [addAction, deleteAction])
        
        memoEditButton.showsMenuAsPrimaryAction = true
        memoEditButton.menu = menu
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

}
extension ReadingViewController: ReadingInProgressViewDelegate {
    func deleteReadingCell(_ view: ReadingInProgressView, didSelectItemAt index: Int) {
        viewModel.deleteBook(targetIdx: index)
    }
    func editReadingCell(_ view: HighlightTableViewCell, didSelectItemAt index: Int) {

        coordinator?.showEditReadingInProgress(bookId: viewModel.bookDetail?.id, index: index)
    }

}
