//
//  ArchiveViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import Combine
import SnapKit

final class ArchiveViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    var viewModel: ArchiveViewModel
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    var isDeleteMode: Bool {
        get { return tableView.isEditing }
        set { tableView.setEditing(newValue, animated: true) }
    }
    
    // Search components
    private let searchBar = UISearchBar()
    
    private let filterIcon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Filter components
    private let categoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    private let filterTypeContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.isHidden = true
        return stackView
    }()
    
    private let statusFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Status", for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        return button
    }()
    
    private let categoryFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Category", for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        return button
    }()
    
    private let feelingFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Feeling", for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        return button
    }()
    
    // Changed from UIScrollView to UIView
    private let tagContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let tagFlowLayout: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private let tableView = UITableView()
    
    private var selectedFilterType: FilterType = .none {
        didSet {
            updateTagView()
        }
    }
    
    private enum FilterType {
        case none, status, category, feeling
    }
    
    deinit {
        coordinator?.popVC()
    }
    
    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        viewModel.$bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    override func configureHierarchy() {
        // Search components
        view.addSubview(searchBar)
        view.addSubview(filterIcon)
        
        // Filter components
        view.addSubview(filterTypeContainer)
        filterTypeContainer.addArrangedSubview(statusFilterButton)
        filterTypeContainer.addArrangedSubview(categoryFilterButton)
        filterTypeContainer.addArrangedSubview(feelingFilterButton)
        
        view.addSubview(categoriesLabel)
        view.addSubview(tagContainerView)
        tagContainerView.addSubview(tagFlowLayout)
        
        view.addSubview(tableView)
        
        // Register cell for tag collection view
        tagFlowLayout.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        tagFlowLayout.delegate = self
        tagFlowLayout.dataSource = self
    }
    
    override func configureLayout() {
        // Search components layout
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(40)
        }

        filterIcon.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(40)
        }
        // Filter icon positioned below search bar when no filter type is selected
        updateFilterIconConstraints()

        // Filter type buttons
        filterTypeContainer.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.leading.equalTo(filterIcon.snp.trailing).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(40)
        }
        
        // Categories label
        categoriesLabel.snp.makeConstraints { make in
            make.top.equalTo(filterTypeContainer.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        // Tag container view
        tagContainerView.snp.makeConstraints { make in
            make.top.equalTo(categoriesLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(0)// Dynamic height based on content
        }
        
        tagFlowLayout.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            // The collection view will determine its own height
        }
        
        // Table view - will be updated dynamically based on filter state
        updateTableViewConstraints()
    }
    
    private func updateFilterIconConstraints() {
        view.layoutIfNeeded()
        if selectedFilterType == .none {
            // Position filter icon directly below search bar
            filterIcon.snp.remakeConstraints { make in
                make.top.equalTo(searchBar.snp.bottom).offset(8)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
                make.size.equalTo(40)
            }
        } else {
            // Position filter icon below tag container when filter type is selected
            filterIcon.snp.remakeConstraints { make in
                make.top.equalTo(tagContainerView.snp.bottom).offset(8)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
                make.size.equalTo(40)
            }
        }
    }
    
    private func updateTableViewConstraints() {

        if selectedFilterType == .none {
            // Table view starts directly below filter icon when no filter
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(filterIcon.snp.bottom).offset(8)
                make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        } else {
            // Table view starts below filter icon when filter is active
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(filterIcon.snp.bottom).offset(8)
                make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
    
    override func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Library"
        self.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "book"), tag: 1)
        tableView.backgroundColor = .systemBackground
        tableView.register(ArchiveTableViewCell.self, forCellReuseIdentifier: ArchiveTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
        
        // Configure filter buttons
        filterIcon.addTarget(self, action: #selector(filterIconTapped), for: .touchUpInside)
        statusFilterButton.addTarget(self, action: #selector(statusFilterTapped), for: .touchUpInside)
        categoryFilterButton.addTarget(self, action: #selector(categoryFilterTapped), for: .touchUpInside)
        feelingFilterButton.addTarget(self, action: #selector(feelingFilterTapped), for: .touchUpInside)
    }
    
    @objc private func deleteButtonTapped() {
        if isDeleteMode {
            isDeleteMode = false
            deleteButton.setTitle("Edit", for: .normal)
        } else {
            isDeleteMode = true
            deleteButton.setTitle("Done", for: .normal)
            tableView.reloadData()
        }
    }
    
    @objc private func filterIconTapped() {
        // Toggle filter type container visibility
        let isHidden = filterTypeContainer.isHidden
        filterTypeContainer.isHidden = !isHidden
        
        // If hiding filter, also hide tags and reset selected filter type
        if isHidden == false {
            categoriesLabel.isHidden = true
            tagContainerView.isHidden = true
            selectedFilterType = .none
            updateFilterIconConstraints()
            updateTableViewConstraints()
        }
    }
    
    @objc private func statusFilterTapped() {
        selectedFilterType = .status
        updateFilterButtonStyles()
        categoriesLabel.isHidden = false
        categoriesLabel.text = "Status"
        tagContainerView.isHidden = false
        updateFilterIconConstraints()
        updateTableViewConstraints()
    }
    
    @objc private func categoryFilterTapped() {
        selectedFilterType = .category
        updateFilterButtonStyles()
        categoriesLabel.isHidden = false
        categoriesLabel.text = "Categories"
        tagContainerView.isHidden = false
        updateFilterIconConstraints()
        updateTableViewConstraints()
    }
    
    @objc private func feelingFilterTapped() {
        selectedFilterType = .feeling
        updateFilterButtonStyles()
        categoriesLabel.isHidden = false
        categoriesLabel.text = "Feeling"
        tagContainerView.isHidden = false
        updateFilterIconConstraints()
        updateTableViewConstraints()
    }
    
    private func updateFilterButtonStyles() {
        // Reset all button styles
        [statusFilterButton, categoryFilterButton, feelingFilterButton].forEach { button in
            button.backgroundColor = .systemBackground
            button.setTitleColor(.systemBlue, for: .normal)
        }
        
        // Set selected button style
        switch selectedFilterType {
        case .status:
            statusFilterButton.backgroundColor = .systemBlue
            statusFilterButton.setTitleColor(.white, for: .normal)
        case .category:
            categoryFilterButton.backgroundColor = .systemBlue
            categoryFilterButton.setTitleColor(.white, for: .normal)
        case .feeling:
            feelingFilterButton.backgroundColor = .systemBlue
            feelingFilterButton.setTitleColor(.white, for: .normal)
        case .none:
            break
        }
    }
    
    private func updateTagView() {
        tagFlowLayout.reloadData()
        
        // After reloading data, we need to update the size of the container
        // This will be called after layout has occurred
        DispatchQueue.main.async {
            self.updateTagContainerHeight()
        }
    }
    
    private func updateTagContainerHeight() {
        // Get the content size of the collection view
        let contentHeight = tagFlowLayout.collectionViewLayout.collectionViewContentSize.height
        
        // Update the tag container height
        tagContainerView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight + 16) // Add some padding
        }
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    private func applyFilters() {
        // Get all selected tags from collection view
        // Implementation depends on your data model
        // viewModel.applyFilters(type: selectedFilterType, tags: selectedTags)
    }
}

// MARK: - UICollectionViewDataSource
extension ArchiveViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedFilterType {
        case .status:
            return 3 // ["Finished", "Reading", "Want to Read"]
        case .category:
            return 9 // ["Adventure", "Biography", "Fantasy", "Fiction", "Literary Fiction", "Memoir", "Psychology", "Science Fiction", "Self-help"]
        case .feeling:
            return 5 // ["Happy", "Sad", "Inspiring", "Thought-provoking", "Relaxing"]
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        
        var tags: [String] = []
        switch selectedFilterType {
        case .status:
            tags = ["Finished", "Reading", "Want to Read"]
        case .category:
            tags = ["Adventure", "Biography", "Fantasy", "Fiction", "Literary Fiction", "Memoir", "Psychology", "Science Fiction", "Self-help"]
        case .feeling:
            tags = ["Happy", "Sad", "Inspiring", "Thought-provoking", "Relaxing"]
        case .none:
            tags = []
        }
        
        if indexPath.item < tags.count {
            cell.configure(with: tags[indexPath.item])
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ArchiveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
        
        // Toggle selected state
        cell.toggleSelection()
        
        // Apply filters
        applyFilters()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArchiveViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var tags: [String] = []
        switch selectedFilterType {
        case .status:
            tags = ["Finished", "Reading", "Want to Read"]
        case .category:
            tags = ["Adventure", "Biography", "Fantasy", "Fiction", "Literary Fiction", "Memoir", "Psychology", "Science Fiction", "Self-help"]
        case .feeling:
            tags = ["Happy", "Sad", "Inspiring", "Thought-provoking", "Relaxing"]
        case .none:
            tags = []
        }
        
        if indexPath.item < tags.count {
            let label = UILabel()
            label.text = tags[indexPath.item]
            label.sizeToFit()
            
            // Width = text width + padding
            let width = label.frame.width + 32
            
            return CGSize(width: width, height: 32)
        }
        
        return CGSize(width: 100, height: 32)
    }
}

// MARK: - Tag Cell
class TagCollectionViewCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private var isTagSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        isTagSelected = false
        updateAppearance()
    }
    
    func toggleSelection() {
        isTagSelected = !isTagSelected
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isTagSelected {
            contentView.backgroundColor = .systemBlue
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .systemGray6
            titleLabel.textColor = .darkGray
        }
    }
}
extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveTableViewCell.identifier, for: indexPath) as! ArchiveTableViewCell
        let item = viewModel.bookList[indexPath.row]
        cell.configure(item: item)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetId = viewModel.bookList[indexPath.row].id
        coordinator?.showReading(bookId: targetId)
    }
    // Add to UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from data source

            viewModel.deleteBook(index: indexPath.row)
            // Delete the row from the table
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Add to UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
