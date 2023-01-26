//
//  ViewController.swift
//  filmBaseHW3
//
//  Created by Алексей Щербаков on 01.11.2022.
//

import UIKit

protocol MainView: UITableViewDataSource, UITableViewDelegate {
    func saveFilm(_ film: FilmData)
}


class FilmsTable: UIViewController, MainView {
    @IBOutlet private var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private var films: [FilmData] = [
        FilmData(filmName: "Линейная алгебра", producer: "ЕАиЕВ", year: 1112, stars: 4),
        FilmData(filmName: "Пупа", producer: "Зарплата", year: 2023, stars: 2),
        FilmData(filmName: "Драйв", producer: "Райан Гослинг", year: 2222, stars: 4),
        FilmData(filmName: "Лупа", producer: "Зарплата", year: 5222, stars: 1),
    ]
    
    private var years: [Int] {
        get {
            films.map({film in film.year})
        }
    }
    
    private lazy var uniqYears: [Int] = Array(Set(years)).sorted(by: { x, y in x < y })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FilmCell", bundle: nil), forCellReuseIdentifier: "FilmCell")
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.sectionIndexColor = .systemGreen
    }
    
    @objc
    private func refreshData(_ sender: Any) {
        uniqYears.shuffle()
        films.shuffle()
        films = films.sorted(by: { lFilm, rFilm in uniqYears.firstIndex(of: lFilm.year)! < uniqYears.firstIndex(of: rFilm.year)! || uniqYears.firstIndex(of: lFilm.year)! == uniqYears.firstIndex(of: rFilm.year)! && lFilm.year < rFilm.year })
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func addFilm(_ sender: UIButton) {
        let filmForm = FilmForm()
        filmForm.mainView = self
        self.navigationController?.pushViewController(filmForm, animated: true)
        print(films)
        
    }
    
    func saveFilm(_ newFilm: FilmData) {
        
        // FOR CHECK THAT CELLS ARE MUTABLE
        print(films)
        
        
        let insertAt = (films.lastIndex(where: {film in film.year <= newFilm.year}) ?? -1) + 1
        let section = uniqYears.filter({year in year < newFilm.year}).count
        if !uniqYears.contains(newFilm.year) {
            uniqYears.insert(newFilm.year, at: section)
            tableView.insertSections([section], with: .automatic)
        }
        films.insert(newFilm, at: insertAt)
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: section), section: section)], with: .automatic)
    }
    
    func deleteFilm(_ indexPath: IndexPath) {
        let year = uniqYears[indexPath.section]
        let index = films.firstIndex(where: {film in film.year == year})! + indexPath.item
        films.remove(at: index)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if tableView.numberOfRows(inSection: indexPath.section) == 0 {
            uniqYears.remove(at: uniqYears.firstIndex(of: year)!)
            tableView.deleteSections([indexPath.section], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return uniqYears.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return years.filter({ year in year == uniqYears[section]}).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(uniqYears[section])
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return uniqYears.map({year in String(year)})
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell") as? FilmCell else {
            return UITableViewCell()
        }
        let year = uniqYears[indexPath.section]
        cell.setup(films.filter({film in film.year == year})[indexPath.row])
        return cell
    }
    
    // TODO: reverse the direction of swipe
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.deleteFilm(indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

