//
//  HomeViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine
class HomeViewController: BaseViewController {
    weak var coordinator: HomeCoordinator?
    var viewModel: HomeViewModel
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let homeLabel = UILabel()
    private let divider : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    private let settingsButton = UIButton()
    private let horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let centerView = UIView()
    private let centerTextLabel = UILabel()
    
    private let bottomLeftTagView = UIView()
    private let bottomRightView = UIView()
    private let bookCoverImageView = UIImageView()
    private let rightViewTextLabel = UILabel()
    
    private var tags = ["family", "playing", "Drama", "pet", "Romance", "thriller", "Travel", "home", "feel"]
    private var bookCategories = ["Educated", "Klara and the...", "The Midnight...", "Atomi..."]
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func configureHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(homeLabel)
        view.addSubview(settingsButton)
        view.addSubview(divider)
        view.addSubview(horizontalCollectionView)
        view.addSubview(centerView)
        centerView.addSubview(centerTextLabel)
        view.addSubview(bottomLeftTagView)
        view.addSubview(bottomRightView)
        bottomRightView.addSubview(rightViewTextLabel)
        bottomRightView.addSubview(bookCoverImageView)

    }
    override func configureLayout() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        homeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(24)
        }
        divider.snp.makeConstraints { make in
            make.top.equalTo(homeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        horizontalCollectionView.snp.makeConstraints { make in
            make.top.equalTo(homeLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        centerView.snp.makeConstraints { make in
            make.top.equalTo(horizontalCollectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        centerTextLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        bottomLeftTagView.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 50) * 0.5)
            make.height.equalTo(200)
        }
        bottomRightView.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo((view.frame.width - 50) * 0.5)
            make.height.equalTo(200)
        }
        rightViewTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        bookCoverImageView.snp.makeConstraints { make in
            make.top.equalTo(rightViewTextLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(100)
        }
    }
    override func configureView() {
        view.backgroundColor = .white
        // top
        titleLabel.text = "Memos"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)

        homeLabel.text = "Home"
        homeLabel.font = .systemFont(ofSize: 32, weight: .bold)

        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .black
        
        //Scrollview
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.showsHorizontalScrollIndicator = false
        horizontalCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        horizontalCollectionView.backgroundColor = .clear
        horizontalCollectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        
        //centerview
        centerView.backgroundColor = .systemGray6
        centerView.layer.cornerRadius = 12

        
        centerTextLabel.text = "오늘의 나는 내일을 만든다"
        centerTextLabel.font = .systemFont(ofSize: 20, weight: .medium)
        centerTextLabel.textAlignment = .center
        
        //bottomView
        // Bottom Left Tag View
        bottomLeftTagView.backgroundColor = .systemGray6
        bottomLeftTagView.layer.cornerRadius = 12

        
        setupTagsInView()
        
        // Bottom Right View
        bottomRightView.backgroundColor = .systemGray6
        bottomRightView.layer.cornerRadius = 12

        
        // Right View Text Label
        rightViewTextLabel.text = "마지막 페이지를 작성해주세요"
        rightViewTextLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rightViewTextLabel.textAlignment = .center
        rightViewTextLabel.numberOfLines = 0
 
        
        // Book Cover Image View
        bookCoverImageView.image = UIImage(named: "book_cover")
        bookCoverImageView.contentMode = .scaleAspectFill
        bookCoverImageView.clipsToBounds = true
        bookCoverImageView.layer.cornerRadius = 8

    }

    private func setupTagsInView() {
        let tagWidth: CGFloat = (bottomLeftTagView.frame.width - 30) / 3
        let tagHeight: CGFloat = 30
        let horizontalSpacing: CGFloat = 5
        let verticalSpacing: CGFloat = 10
        
        for (index, tagText) in tags.enumerated() {
            let row = index / 3
            let column = index % 3
            
            let tagView = createTagView(withText: tagText)
            bottomLeftTagView.addSubview(tagView)
            
            tagView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20 + (row * Int((tagHeight + verticalSpacing))))
                make.leading.equalToSuperview().offset(10 + (column * Int((tagWidth + horizontalSpacing))))
                make.width.equalTo(tagWidth)
                make.height.equalTo(tagHeight)
            }
        }
    }
    
    private func createTagView(withText text: String) -> UIView {
        let tagContainer = UIView()
        tagContainer.backgroundColor = .white
        tagContainer.layer.cornerRadius = 15
        
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.font = .systemFont(ofSize: 12)
        tagLabel.textAlignment = .center
        tagContainer.addSubview(tagLabel)
        
        tagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return tagContainer
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        cell.configure(with: bookCategories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 150)
    }
}

// MARK: - BookCell
class BookCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray4
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        // Title Label
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        imageView.image = UIImage(named: "book_\(title.lowercased().prefix(3))")
    }
}

