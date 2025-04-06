//
//  StatisticsViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine


class StatisticsViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    weak var coordinator: StatsCoordinator?
    var viewModel: StatsViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Statistics"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    // Book count this month view
    private lazy var booksThisMonthView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var booksThisMonthTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Books This Month"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var booksThisMonthCountLabel: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var booksThisMonthIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "book")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Total books view
    private lazy var totalBooksView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var totalBooksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Books"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var totalBooksCountLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var totalBooksIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chart.bar.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Reading streak view
    private lazy var booksThisYearhView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var booksThisYearTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Streak"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var booksThisYearhCountLabel: UILabel = {
        let label = UILabel()
        label.text = "7 days"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var readingStreakIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Calendar
    private lazy var calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "June 2023"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var calendarPrevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarNextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        return datePicker
    }()
    private var contentViewOriginalCenter: CGPoint?
    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self

    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Statistics"

    }
    
    override func bind() {
        let input = StatsViewModel.Input()
        let output = viewModel.transform(input: input)
        viewModel.$bookStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let self = self, let stats = stats else {return}
                self.setupUI(stats: stats)
            }
            .store(in: &cancellables)
        viewModel.$bookDetail
             .receive(on: DispatchQueue.main)
             .sink { [weak self] books in
                 guard let self = self, let books = books, !books.isEmpty else { return }
                 self.showBooksInDate(books: books)
             }
             .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSNotification.Name("BooksInDateViewDismissed"))
            .sink { [weak self] _ in
                self?.resetContentViewPosition()
            }
            .store(in: &cancellables)
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PartialPresentationController(presentedViewController: presented, presenting: presenting)
    }
    private func showBooksInDate(books: [HomeBookEntity]) {
        // Save the original position of content view
        contentViewOriginalCenter = contentView.center
        
        // Animate the content view upward
        UIView.animate(withDuration: 0.3) {
            self.contentView.center.y -= 180
        }
        
        // Use coordinator to present the BooksInDateViewController
        coordinator?.showBooksInDate(books: books)
    }
    private func resetContentViewPosition() {
        if let originalCenter = contentViewOriginalCenter {
            UIView.animate(withDuration: 0.3) {
                self.contentView.center = originalCenter
            }
        }
    }
    private func setupUI(stats: BookStats) {
        booksThisMonthCountLabel.text = String(stats.monthCount)
        totalBooksCountLabel.text = String(stats.totalCount)
        booksThisYearhCountLabel.text = String(stats.yearCount)
    }
    // MARK: - View 계층 구조 설정
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add components to content view
        contentView.addSubview(titleLabel)
        
        // Add stats cards
        contentView.addSubview(booksThisMonthView)
        booksThisMonthView.addSubview(booksThisMonthTitleLabel)
        booksThisMonthView.addSubview(booksThisMonthCountLabel)
        booksThisMonthView.addSubview(booksThisMonthIconImageView)
        
        contentView.addSubview(totalBooksView)
        totalBooksView.addSubview(totalBooksTitleLabel)
        totalBooksView.addSubview(totalBooksCountLabel)
        totalBooksView.addSubview(totalBooksIconImageView)
        
        contentView.addSubview(booksThisYearhView)
        booksThisYearhView.addSubview(booksThisYearTitleLabel)
        booksThisYearhView.addSubview(booksThisYearhCountLabel)
        booksThisYearhView.addSubview(readingStreakIconImageView)
        
        // Add calendar
        contentView.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendarTitleLabel)
        calendarContainerView.addSubview(calendarPrevButton)
        calendarContainerView.addSubview(calendarNextButton)
        calendarContainerView.addSubview(calendarView)
    }
    
    // MARK: - View 레이아웃 설정
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            // Height will be determined by content
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        
        // Books this month view
        booksThisMonthView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        booksThisMonthTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthView).offset(20)
            make.leading.equalTo(booksThisMonthView).offset(20)
        }
        
        booksThisMonthCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisMonthView).offset(20)
        }
        
        booksThisMonthIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisMonthView)
            make.trailing.equalTo(booksThisMonthView).offset(-20)
            make.width.height.equalTo(40)
        }
        
        // Total books view
        totalBooksView.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        totalBooksTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(totalBooksView).offset(20)
            make.leading.equalTo(totalBooksView).offset(20)
        }
        
        totalBooksCountLabel.snp.makeConstraints { make in
            make.top.equalTo(totalBooksTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(totalBooksView).offset(20)
        }
        
        totalBooksIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(totalBooksView)
            make.trailing.equalTo(totalBooksView).offset(-20)
            make.width.height.equalTo(40)
        }
        
        // Reading streak view
        booksThisYearhView.snp.makeConstraints { make in
            make.top.equalTo(totalBooksView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        booksThisYearTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView).offset(20)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        booksThisYearhCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        readingStreakIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisYearhView)
            make.trailing.equalTo(booksThisYearhView).offset(-20)
            make.width.height.equalTo(40)
        }
        
        // Calendar container
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(350)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
        calendarTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView).offset(16)
            make.centerX.equalTo(calendarContainerView)
        }
        
        calendarPrevButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarTitleLabel)
            make.leading.equalTo(calendarContainerView).offset(20)
            make.width.height.equalTo(30)
        }
        
        calendarNextButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarTitleLabel)
            make.trailing.equalTo(calendarContainerView).offset(-20)
            make.width.height.equalTo(30)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(calendarTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(calendarContainerView).offset(10)
            make.trailing.equalTo(calendarContainerView).offset(-10)
            make.bottom.equalTo(calendarContainerView).offset(-10)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .white
        
    }

  
    // MARK: - Actions
    @objc private func dateSelected(_ sender: UIDatePicker) {
        viewModel.getBooksInDate(target: sender.date)
    }

    @objc private func previousMonthTapped() {
        guard let currentDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarView.date) else { return }
        calendarView.setDate(currentDate, animated: true)
    }
    
    @objc private func nextMonthTapped() {
        guard let currentDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarView.date) else { return }
        calendarView.setDate(currentDate, animated: true)
    }
}
class PartialPresentationController: UIPresentationController {
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        // 화면 하단에 표시될 높이 계산 (원하는 높이로 조정 가능)
        let height: CGFloat = 300 // 책 리스트가 보일 정도의 높이
        
        return CGRect(
            x: 0,
            y: containerView.frame.height - height,
            width: containerView.frame.width,
            height: height
        )
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // 배경 dimView 추가
        dimView.frame = containerView.bounds
        containerView.insertSubview(dimView, at: 0)
        
        // 탭 제스처 추가 (dimView 탭시 dismiss)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimView.addGestureRecognizer(tapGesture)
        
        // 애니메이션
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.0
        })
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true) {
            // Notify that view was dismissed
            NotificationCenter.default.post(name: NSNotification.Name("BooksInDateViewDismissed"), object: nil)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
