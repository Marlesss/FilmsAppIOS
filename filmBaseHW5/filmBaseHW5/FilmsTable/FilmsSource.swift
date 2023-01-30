//
//  FilmsSource.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 27.01.2023.
//

import UIKit

class FilmsSource: NSObject, UITableViewDataSource {

    // TODO: Private
    private let tableView: UITableView

    public var films: [FilmData] = [
//        FilmData(filmName: "Линейная алгебра", producer: "ЕАиЕВ", year: 1112, stars: 4),
//        FilmData(filmName: "Пупа", producer: "Зарплата", year: 2023, stars: 2),
//        FilmData(filmName: "Драйв", producer: "Райан Гослинг", year: 2222, stars: 4),
//        FilmData(filmName: "Лупа", producer: "Зарплата", year: 5222, stars: 1),
    ]
    
    private var years: [Int] {
        get {
            films.map({film in film.year})
        }
    }
    
    private lazy var uniqYears: [Int] = Array(Set(years)).sorted(by: { x, y in x < y })

    init(_ tableView: UITableView) {
        self.tableView = tableView
        super.init()
        loadAllData()
    }
    
    private func loadAllData() {
        1 + 1
    }
        
    public func refreshData() {
        uniqYears.shuffle()
        films.shuffle()
        films = films.sorted(by: { lFilm, rFilm in uniqYears.firstIndex(of: lFilm.year)! < uniqYears.firstIndex(of: rFilm.year)! || uniqYears.firstIndex(of: lFilm.year)! == uniqYears.firstIndex(of: rFilm.year)! && lFilm.year < rFilm.year })
    }
    
    
    public func saveFilm(_ newFilm: FilmData) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilmCell") as? FilmCell else {
            return UITableViewCell()
        }
        let year = uniqYears[indexPath.section]
        cell.setup(films.filter({film in film.year == year})[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

}
