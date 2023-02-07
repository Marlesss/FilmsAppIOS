//
//  ViewController.swift
//  filmBaseHW3
//
//  Created by Алексей Щербаков on 01.11.2022.
//

import UIKit

class FilmsTable: UIViewController, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    
    public var rootViewController: SignInView?
    
//    private let refreshControl = UIRefreshControl()
    
    private lazy var filmsSource = FilmsSource(tableView, userToken!)
    
    private var userToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userToken = rootViewController!.currentUserToken
        tableView.dataSource = filmsSource
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "FilmCell", bundle: nil), forCellReuseIdentifier: "FilmCell")
        
//        tableView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.sectionIndexColor = .systemGreen
    }
    
//    @objc
//    private func refreshData(_ sender: Any) {
//        filmsSource.refreshData()
//        tableView.reloadData()
//        refreshControl.endRefreshing()
//    }
    
    @IBAction func addFilm(_ sender: UIButton) {
        let filmForm = FilmForm()
        filmForm.filmsTable = self
        self.navigationController?.pushViewController(filmForm, animated: true)
    }
    
    func saveFilm(_ newFilm: FilmData) {
        filmsSource.saveFilm(newFilm)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.filmsSource.deleteFilm(indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

