//
//  HomeViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine
import Kingfisher

import RealmSwift

class HomeViewController: BaseViewController {
    weak var coordinator: HomeCoordinator?
    var viewModel: HomeViewModel
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - Properties
    private let settingsButton = UIButton()
    private let horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let centerView = UIView()
    private let centerTextLabel = UILabel()

    private let jarImageView = UIImageView() // 병 이미지를 위한 ImageView 추가
    private let bottomLeftTagView = UIView()
    private let bottomRightView = UIView()
    private let bookCoverImageView = UIImageView()
    private let bookCoverTapGesture = UITapGestureRecognizer()
    private let rightViewTextLabel = UILabel()
    private let searchButton = UIButton()
    
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
    override func bind() {
        let input = HomeViewModel.Input()
        let output = viewModel.transform(input: input)
        viewModel.$bookDetail.receive(on: DispatchQueue.main)
            .sink { [weak self] books in
                guard let self = self else {return}
                self.horizontalCollectionView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$selectedTags.receive(on: DispatchQueue.main)
            .sink { [weak self] tags in
                guard let self = self else {return}
                //self.setupTagsInView(with: tags)\
                self.setupTagsInView(with: self.tags)
            }
            .store(in: &cancellables)
        viewModel.$sampleBook.receive(on: DispatchQueue.main)
            .sink { [weak self] book in
                guard let self = self else {return}
                ImageFormatter.shared.setImage(target: self.bookCoverImageView, path: book?.bookDetail.imagePath)
            }
            .store(in: &cancellables)
    }
    override func configureHierarchy() {
        view.addSubview(settingsButton)
        view.addSubview(horizontalCollectionView)
        view.addSubview(centerView)
        centerView.addSubview(centerTextLabel)
        view.addSubview(bottomLeftTagView)
        view.addSubview(bottomRightView)
        bottomRightView.addSubview(rightViewTextLabel)
        bottomRightView.addSubview(bookCoverImageView)
        view.addSubview(searchButton)

    }
    override func configureLayout() {

        horizontalCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
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
            make.width.equalTo(80)
            make.height.equalTo(120)
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(bottomLeftTagView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(centerView)
            make.height.equalTo(40)
        }
    }
    override func configureView() {
        view.backgroundColor = .white
        self.navigationItem.title = "Last Page"
        self.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
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

        
        centerTextLabel.text = "쌈뽕한 한 문장"
        centerTextLabel.font = .systemFont(ofSize: 20, weight: .medium)
        centerTextLabel.textAlignment = .center
        
        //bottomView
        // Bottom Left Tag View
        bottomLeftTagView.backgroundColor = .systemGray6
        bottomLeftTagView.layer.cornerRadius = 12

    
        
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
        bookCoverImageView.isUserInteractionEnabled = true
        bookCoverTapGesture.addTarget(self, action: #selector(bookCoverTapped))
        bookCoverImageView.addGestureRecognizer(bookCoverTapGesture)
        
        //search
        searchButton.setTitle("Search And Add Book", for: .normal)
        searchButton.backgroundColor = .lightGray
        searchButton.clipsToBounds = true
        searchButton.layer.cornerRadius = 8
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

    }
    @objc private func searchButtonTapped() {
        coordinator?.showSearch()
    }
    @objc private func bookCoverTapped() {
        coordinator?.showReading(bookId: viewModel.sampleBook?.id)
    }

    // setupTagsInView 메서드를 수정
    private func setupTagsInView(with tags: [String]) {
        // 기존 태그 뷰들을 제거
        bottomLeftTagView.subviews.forEach { $0.removeFromSuperview() }
        
        // jar 이미지 추가 (배경으로 사용)
        jarImageView.image = nil
        jarImageView.contentMode = .scaleToFill
        bottomLeftTagView.addSubview(jarImageView)
        
        jarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 태그들을 담을 컨테이너 뷰 (jar 안에 위치)
        let tagsContainerView = UIView()
        bottomLeftTagView.addSubview(tagsContainerView)
        
        tagsContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-30) // jar 바닥에서 여백
            make.top.equalToSuperview().offset(50) // jar 윗부분 여백
        }
        
        // 태그 뷰들을 바닥부터 쌓기 위한 설정
        let tagHeight: CGFloat = 25
        let tagSpacing: CGFloat = 8
        let maxTagsPerRow = 3
        
        // 행과 열을 계산하기 위한 변수들
        var currentRow = 0
        var currentColumn = 0
        var rowTags: [[String]] = []
        var currentRowTags: [String] = []
        
        // 태그를 행과 열로 분리
        for tag in tags {
            currentRowTags.append(tag)
            currentColumn += 1
            
            if currentColumn >= maxTagsPerRow {
                rowTags.append(currentRowTags)
                currentRowTags = []
                currentColumn = 0
                currentRow += 1
            }
        }
        
        // 마지막 행이 완성되지 않았다면 추가
        if !currentRowTags.isEmpty {
            rowTags.append(currentRowTags)
        }
        
        // 태그를 아래에서부터 위로 쌓기 위해 행 순서를 뒤집음
        rowTags.reverse()
        
        // 태그 뷰 생성 및 배치
        for (rowIndex, rowOfTags) in rowTags.enumerated() {
            for (colIndex, tagText) in rowOfTags.enumerated() {
                let tagView = createTagView(withText: tagText)
                tagsContainerView.addSubview(tagView)
                
                // 가용 너비를 기반으로 태그 너비 계산
                let totalAvailableWidth = tagsContainerView.frame.width > 0 ? tagsContainerView.frame.width : bottomLeftTagView.frame.width - 40
                let tagWidth = (totalAvailableWidth - (CGFloat(maxTagsPerRow - 1) * tagSpacing)) / CGFloat(maxTagsPerRow)
                
                tagView.snp.makeConstraints { make in
                    make.bottom.equalToSuperview().offset(-CGFloat(rowIndex) * (tagHeight + tagSpacing))
                    
                    // 중앙 정렬을 위한 계산
                    if rowOfTags.count < maxTagsPerRow {
                        // 태그가 적을 경우 중앙에 정렬
                        let totalTagsWidth = CGFloat(rowOfTags.count) * tagWidth + CGFloat(rowOfTags.count - 1) * tagSpacing
                        let leftOffset = (totalAvailableWidth - totalTagsWidth) / 2 + CGFloat(colIndex) * (tagWidth + tagSpacing)
                        make.leading.equalToSuperview().offset(leftOffset)
                    } else {
                        // 최대 태그 수일 경우 균등하게 분배
                        make.leading.equalToSuperview().offset(CGFloat(colIndex) * (tagWidth + tagSpacing))
                    }
                    
                    make.width.equalTo(tagWidth)
                    make.height.equalTo(tagHeight)
                }
            }
        }
    }

    // 태그 뷰 생성 함수 (기존 함수 유지)
    private func createTagView(withText text: String) -> UIView {
        let tagContainer = UIView()
        tagContainer.backgroundColor = .white
        tagContainer.layer.cornerRadius = 12
        
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

    // 태그 업데이트를 위한 메서드 추가
    func updateTags(with tags: [String]) {
        setupTagsInView(with: tags)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.bookDetail.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let item = viewModel.bookDetail[indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 170)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemId = viewModel.bookDetail[indexPath.item].id
        coordinator?.showReading(bookId: itemId)
    }
}

// MARK: - BookCell
class BookCell: UICollectionViewCell {
    private let highlightContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureLayout() {
        contentView.addSubview(highlightContainerView)
        highlightContainerView.addSubview(imageView)
        highlightContainerView.addSubview(titleLabel)
        
        highlightContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(120)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.horizontalEdges.equalTo(imageView)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        imageView.image = nil
    }
    private func setupCell() {
        
        highlightContainerView.backgroundColor = .white
        highlightContainerView.layer.cornerRadius = 12
        highlightContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        highlightContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        highlightContainerView.layer.shadowOpacity = 1
        highlightContainerView.layer.shadowRadius = 3
        
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray4

        // Title Label
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
    }
    
    func configure(with item: HomeBookEntity) {
        titleLabel.text = item.bookDetail.title
        ImageFormatter.shared.setImage(target: imageView, path: item.bookDetail.imagePath)
       
    }

}

