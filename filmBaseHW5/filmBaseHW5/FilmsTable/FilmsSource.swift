//
//  FilmsSource.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 27.01.2023.
//

import UIKit
import Dispatch

class FilmsSource: NSObject, UITableViewDataSource {

    private let tableView: UITableView
    
    private let userToken: String

    public var films: [ServerAPI.Movie] = []
    
    private var years: [Int] {
        get {
            films.map({film in film.reliseDate})
        }
    }
    
    private lazy var uniqYears: [Int] = Array(Set(years)).sorted(by: { x, y in x < y })
    
    init(_ tableView: UITableView, _ userToken: String) {
        self.userToken = userToken
        self.tableView = tableView
        super.init()
        loadAllData()
    }
    
    private func loadAllData(store: [ServerAPI.Movie] = [], cursor: Int? = nil) {
        ViewController.serverAPI.getMovies(cursor: cursor, count: 5, token: userToken) { result in
            if case let .success(moviesResponse) = result {
                let newStore = store + moviesResponse.movies
                if let newCursor = moviesResponse.cursor {
                    DispatchQueue.main.sync {
                        self.loadAllData(store: newStore, cursor: newCursor)
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.loadMaxIdFilm(store: newStore, preMaxId: newStore.map({ $0.id ?? -1 }).max(by: { $0 < $1 }) ?? 0)
                    }
                }
            }
        }
    }
    
    private func loadMaxIdFilm(store: [ServerAPI.Movie], preMaxId: Int, cursorDelta: Int = 5) {
        ViewController.serverAPI.getMovies(cursor: preMaxId + cursorDelta, count: 1, token: userToken) { result in
            if case let .success(moviesResponse) = result {
                let maxId = moviesResponse.movies.map({ $0.id ?? -1 }).max(by: { $0 > $1 }) ?? 0
                if preMaxId >= maxId {
                    DispatchQueue.main.sync {
                        self.loadMaxIdFilm(store: store, preMaxId: preMaxId, cursorDelta: cursorDelta * 2)
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.dataLoaded(store: store + [moviesResponse.movies.filter { movie in movie.id == maxId }[0]])
                    }
                }
            }
        }
    }
    
    private func dataLoaded(store: [ServerAPI.Movie]) {
        self.films = store
        self.uniqYears = Array(Set(years)).sorted(by: { x, y in x < y })
        tableView.reloadData()
    }
        
//    public func refreshData() {
//        uniqYears.shuffle()
//        films.shuffle()
//        films = films.sorted(by: { lFilm, rFilm in uniqYears.firstIndex(of: lFilm.year)! < uniqYears.firstIndex(of: rFilm.year)! || uniqYears.firstIndex(of: lFilm.year)! == uniqYears.firstIndex(of: rFilm.year)! && lFilm.year < rFilm.year })
//    }
    
    
    public func saveFilm(_ newFilm: FilmData) {
        ServerAPI.Movie.make(from: newFilm, token: userToken) { movieResult in
            switch movieResult{
            case let .success(movie):
                DispatchQueue.main.sync {
                    self.insertFilm(movie)
                }
            case let .failure(err):
                print("Got error \(err)")
            }
        }
    }
    
    private func insertFilm(_ newFilm: ServerAPI.Movie) {
        let insertAt = (films.lastIndex(where: {film in film.reliseDate <= newFilm.reliseDate}) ?? -1) + 1
        let section = uniqYears.filter({year in year < newFilm.reliseDate}).count
        if !uniqYears.contains(newFilm.reliseDate) {
            uniqYears.insert(newFilm.reliseDate, at: section)
            tableView.insertSections([section], with: .automatic)
        }
        films.insert(newFilm, at: insertAt)
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: section), section: section)], with: .automatic)
    }
    
    func deleteFilm(_ indexPath: IndexPath) {
        let year = uniqYears[indexPath.section]
        let index = films.firstIndex(where: {film in film.reliseDate == year})! + indexPath.item
        let movie = films[index]
        ViewController.serverAPI.deleteMovie(id: movie.id!, token: userToken) { deleteResult in
            if case let .failure(err) = deleteResult {
                print("Got err \(err)")
            }
        }
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
        cell.setup(films.filter({film in film.reliseDate == year})[indexPath.row], token: userToken)
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

}
