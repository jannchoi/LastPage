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

class HomeViewController: BaseViewController {
    weak var coordinator: HomeCoordinator?
    var viewModel: HomeViewModel
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Scroll Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - UI Properties
    private let settingsButton = UIButton()
    private let horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let centerView = UIView()
    private let centerTextLabel = UILabel()

    private let jarImageView = UIImageView()
    private let bottomLeftTagView = UIView()
    private let bottomRightView = UIView()
    private let bookCoverImageView = UIImageView()
    private let bookCoverTapGesture = UITapGestureRecognizer()
    private let rightViewTextLabel = UILabel()
    private let searchButton = UIButton()

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
                self.setupTagsInView(with: tags)
                
            }
            .store(in: &cancellables)
        viewModel.$sampleBook.receive(on: DispatchQueue.main)
            .sink { [weak self] book in
                guard let self = self else {return}
                ImageFormatter.shared.setImage(target: self.bookCoverImageView, path: book?.bookDetail.imagePath)
            }
            .store(in: &cancellables)
        viewModel.$fetchError.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(settingsButton)
        contentView.addSubview(horizontalCollectionView)
        contentView.addSubview(centerView)
        centerView.addSubview(centerTextLabel)
        contentView.addSubview(bottomLeftTagView)
        contentView.addSubview(bottomRightView)
        bottomRightView.addSubview(rightViewTextLabel)
        bottomRightView.addSubview(bookCoverImageView)
        contentView.addSubview(searchButton)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }


        horizontalCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(186)
        }

        centerView.snp.makeConstraints { make in
            make.top.equalTo(horizontalCollectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }

        centerTextLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(8)
        }

        bottomLeftTagView.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((UIScreen.main.bounds.width - 50) * 0.5)
            make.height.equalTo(200)
        }

        bottomRightView.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo((UIScreen.main.bounds.width - 50) * 0.5)
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
            make.bottom.equalToSuperview().offset(-30)
        }
    }


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //horizontalCollectionView.silverFrame(horizontalOnly: true)  // Only top and bottom borders
        //centerView.silverFrame()
        //bottomLeftTagView.silverFrame()
        //bottomRightView.silverFrame()
        //searchButton.silverFrame()
    }
    override func configureView() {
        view.backgroundColor = .backgroundBase
        self.navigationItem.title = "Last Page"
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.showsHorizontalScrollIndicator = false
        horizontalCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        horizontalCollectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")

        
        //centerview
        centerView.backgroundColor = .white
        centerView.makeShadow()
        
        centerTextLabel.text = TextDataStorage.mainCenterSentence.randomElement()
        centerTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        centerTextLabel.textAlignment = .center
        
        //bottomView
        // Bottom Left Tag View
        bottomLeftTagView.backgroundColor = .white
        bottomLeftTagView.makeShadow()
        // Bottom Right View
        bottomRightView.backgroundColor = .white
        bottomRightView.makeShadow()
        // Right View Text Label
        rightViewTextLabel.text = TextDataStorage.mainBookSentence.randomElement()
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
        searchButton.setTitle("도서 추가하러 가기", for: .normal)
        searchButton.setTitleColor(.mainText, for: .normal)
        let cursorimg = UIImage(systemName: "cursorarrow")?.withTintColor(.mainText)
        searchButton.tintColor = .btnTint.withAlphaComponent(0.7)
        searchButton.setImage(cursorimg, for: .normal)
        searchButton.backgroundColor = .searchBtn
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
        bottomLeftTagView.subviews.forEach { $0.removeFromSuperview() }

        jarImageView.image = nil
        jarImageView.contentMode = .scaleToFill
        bottomLeftTagView.addSubview(jarImageView)
        jarImageView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let tagsContainerView = UIView()
        bottomLeftTagView.addSubview(tagsContainerView)
        tagsContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(50)
        }
        tagsContainerView.layoutIfNeeded()

        let maxWidth = tagsContainerView.frame.width
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let tagHeight: CGFloat = 25
        let tagSpacingX: CGFloat = 8
        let tagSpacingY: CGFloat = 8

        for tag in tags {
            let tagView = createTagView(withText: tag)

            // 텍스트 너비 측정
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.text = tag
            label.sizeToFit()
            let padding: CGFloat = 20 // 좌우 패딩
            let tagWidth = min(label.frame.width + padding, maxWidth)

            // 줄바꿈 체크
            if currentX + tagWidth > maxWidth {
                currentX = 0
                currentY += tagHeight + tagSpacingY
            }

            // 컨테이너 높이 제한 넘으면 그만
            if currentY + tagHeight > tagsContainerView.frame.height {
                break
            }

            tagsContainerView.addSubview(tagView)
            tagView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(currentX)
                make.bottom.equalToSuperview().offset(-currentY)
                make.height.equalTo(tagHeight)
                make.width.equalTo(tagWidth)
            }

            currentX += tagWidth + tagSpacingX
        }
    }

    // 태그 뷰 생성 함수 (기존 함수 유지)
    private func createTagView(withText text: String) -> UIView {
        let tagContainer = UIView()
        tagContainer.backgroundColor = .tagBackground
        tagContainer.layer.borderWidth = 0.5
        tagContainer.layer.borderColor = UIColor.tagBorder.cgColor
        tagContainer.layer.cornerRadius = 12
        
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.textColor = .textSecondary
        tagLabel.font = .systemFont(ofSize: 12)
        tagLabel.textAlignment = .center
        tagLabel.numberOfLines = 1
        tagLabel.lineBreakMode = .byTruncatingTail
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
            make.edges.equalToSuperview()
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
    override func layoutSubviews() {
        super.layoutSubviews()
        //highlightContainerView.silverFrame()
        contentView.clipsToBounds = true
        layer.masksToBounds = true
    }
    private func setupCell() {
        highlightContainerView.backgroundColor = .white
        //highlightContainerView.makeShadow()
        
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .clear

        // Title Label
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
    }
    
    func configure(with item: HomeBookEntity) {
        titleLabel.text = item.bookDetail.title
        ImageFormatter.shared.setImage(target: imageView, path: item.bookDetail.imagePath)
       
    }

}

