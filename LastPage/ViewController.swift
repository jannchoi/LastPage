//
//  ViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/27/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    let search = UIButton()
    let archive = UIButton()
    let statistics = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        search.setTitle("Search", for: .normal)
        search.backgroundColor = .systemBlue
        archive.setTitle("Archive", for: .normal)
        archive.backgroundColor = .systemGreen
        statistics.setTitle("Stats", for: .normal)
        statistics.backgroundColor = .systemRed

        view.addSubview(search)
        view.addSubview(archive)
        view.addSubview(statistics)

        search.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
        }

        archive.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(search.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        statistics.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(archive.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        search.addTarget(self, action: #selector(searchVC), for: .touchUpInside)
        archive.addTarget(self, action: #selector(archiveVC), for: .touchUpInside)
        statistics.addTarget(self, action: #selector(statisticsVC), for: .touchUpInside)
    }
    @objc func searchVC() {
        print(#function)
        let vc = SearchBookViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func archiveVC() {
        print(#function)
    }
    @objc func statisticsVC() {
        print(#function)
    }
}


