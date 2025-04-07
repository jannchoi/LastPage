//
//  CategoryListViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//
import UIKit
import Combine

final class CategoryListViewController: UIViewController {
    private var viewModel: CategoryListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var selectedCategories: [String] = []
    weak var delegate: EditInfoViewControllerDelegate?
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundBase
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "category"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .btnTint
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.backgroundColor = .btnTint
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        return collectionView
    }()
    
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        // Set modal presentation style for partial screen coverage
        modalPresentationStyle = .custom
        modalTransitionStyle = .coverVertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Notify the EditInfoViewController to restore its view position
        if let editInfoVC = presentingViewController as? EditInfoViewController {
            editInfoVC.restoreViewPosition()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Semi-transparent background
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(collectionView)
        containerView.addSubview(confirmButton)
        
        // Configure container view to take up lower portion of screen
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(view.bounds.height * 0.6) // Take up 60% of screen height
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(28)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(confirmButton.snp.top).offset(-16)
        }
        
        // Set up collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        // Add close button action
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Add confirm button action
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss when tapping outside container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        switch viewModel.type {
        case .category:
            titleLabel.text = TextResource.Placeholder.category.text
        case .feeling:
            titleLabel.text = TextResource.Placeholder.feelings.text
        }
    }
    
    private func bindViewModel() {
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        delegate?.updateTags(self, categories: selectedCategories, type: viewModel.type)

        
        dismiss(animated: true)
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = viewModel.categories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = viewModel.categories[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14)
        let maxWidth: CGFloat = collectionView.bounds.width - 40 // 최대 너비 제한
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = (category as NSString).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        let height = ceil(boundingBox.height) + 12 // 상하 패딩 고려
        let width = max(boundingBox.width + 24, 80) // 좌우 패딩 및 최소 너비 고려
        return CGSize(width: width, height: height)
    }

    
    private func calculateCellWidth(for category: String) -> CGFloat {
        // Calculate width based on text length with padding
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (category as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellPadding: CGFloat = 24
        let minWidth: CGFloat = 80
        
        return max(textWidth + cellPadding, minWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = viewModel.categories[indexPath.item]
        
        // Add to selected categories if not already there
        if !selectedCategories.contains(selectedCategory) {
            selectedCategories.append(selectedCategory)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedCategory = viewModel.categories[indexPath.item]
        
        // Remove from selected categories
        if let index = selectedCategories.firstIndex(of: deselectedCategory) {
            selectedCategories.remove(at: index)
        }
    }
}
// Simple cell for category items
class CategoryCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .mainText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .tagBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.tagBorder.cgColor
        contentView.layer.cornerRadius = 15
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = nil
        titleLabel.text = nil
        titleLabel.textColor = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.accentTint.withAlphaComponent(0.2) : .tagBackground
            titleLabel.textColor = isSelected ? .tagBackground : .mainText
        }
    }
}
