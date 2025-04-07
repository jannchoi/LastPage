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
    
    private lazy var titleLabel = UILabel()
    private lazy var booksThisMonthView = UIView()
    private lazy var booksThisMonthTitleLabel = UILabel()
    private lazy var booksThisMonthCountLabel = UILabel()
    private lazy var booksThisMonthIconImageView = UIImageView()
    private lazy var totalBooksView = UIView()
    private lazy var totalBooksTitleLabel = UILabel()
    private lazy var totalBooksCountLabel = UILabel()
    private lazy var totalBooksIconImageView = UIImageView()
    private lazy var booksThisYearhView = UIView()
    private lazy var booksThisYearTitleLabel = UILabel()
    private lazy var booksThisYearCountLabel = UILabel()
    private lazy var booksThisYearIconImageView = UIImageView()
    // Calendar
    private lazy var calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.makeShadow()
        return view
    }()

    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.tintColor = .btnTint
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        booksThisMonthView.silverFrame()
        booksThisYearhView.silverFrame()
        totalBooksView.silverFrame()
        calendarContainerView.silverFrame()
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
        viewModel.$fetchError.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
        
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
        booksThisYearCountLabel.text = String(stats.yearCount)
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
        
        contentView.addSubview(booksThisYearhView)
        booksThisYearhView.addSubview(booksThisYearTitleLabel)
        booksThisYearhView.addSubview(booksThisYearCountLabel)
        booksThisYearhView.addSubview(booksThisYearIconImageView)
        
        contentView.addSubview(totalBooksView)
        totalBooksView.addSubview(totalBooksTitleLabel)
        totalBooksView.addSubview(totalBooksCountLabel)
        totalBooksView.addSubview(totalBooksIconImageView)
        
       
        
        // Add calendar
        contentView.addSubview(calendarContainerView)
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
        booksThisYearhView.snp.makeConstraints { make in
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
        totalBooksView.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        booksThisYearTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView).offset(20)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        booksThisYearCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        booksThisYearIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisYearhView)
            make.trailing.equalTo(booksThisYearhView).offset(-20)
            make.width.height.equalTo(40)
        }

        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(totalBooksView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(350)
            make.bottom.equalTo(contentView).offset(-20)
        }

        calendarView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView).offset(10)
            make.leading.equalTo(calendarContainerView).offset(10)
            make.trailing.equalTo(calendarContainerView).offset(-10)
            make.bottom.equalTo(calendarContainerView).offset(-10)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .backgroundBase // 쿨톤 밝은 회색 배경
        
        titleLabel.text = "Reading Statistics"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .mainText
        
        [booksThisMonthView, totalBooksView, booksThisYearhView, calendarContainerView].forEach {
            $0.backgroundColor = UIColor.white
            $0.layer.cornerRadius = 16
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowRadius = 6
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        booksThisMonthTitleLabel.text = TextResource.Stats.forMonth.text
        booksThisMonthTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        booksThisMonthTitleLabel.textColor = .textSecondary
        
        booksThisMonthCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        booksThisMonthCountLabel.textColor = .mainText
        
        booksThisMonthIconImageView.image = UIImage(systemName: "calendar")
        booksThisMonthIconImageView.tintColor = .accentTint
        booksThisMonthIconImageView.contentMode = .scaleAspectFit

        totalBooksTitleLabel.text = TextResource.Stats.total.text
        totalBooksTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        totalBooksTitleLabel.textColor = .textSecondary

        totalBooksCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        totalBooksCountLabel.textColor = .mainText
        
        totalBooksIconImageView.image = UIImage(systemName: "books.vertical")
        totalBooksIconImageView.tintColor = .accentTint
        totalBooksIconImageView.contentMode = .scaleAspectFit

        booksThisYearTitleLabel.text = TextResource.Stats.forYear.text
        booksThisYearTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        booksThisYearTitleLabel.textColor = .textSecondary

        booksThisYearCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        booksThisYearCountLabel.textColor = .mainText
        
        booksThisYearIconImageView.image = UIImage(systemName: "clock.arrow.circlepath")
        booksThisYearIconImageView.tintColor = .accentTint
        booksThisYearIconImageView.contentMode = .scaleAspectFit
        
        calendarContainerView.backgroundColor = .white
        calendarView.datePickerMode = .date
        calendarView.preferredDatePickerStyle = .inline
        calendarView.tintColor = .accentTint
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
