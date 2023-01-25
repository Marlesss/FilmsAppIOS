import Foundation

public class FilmData: CustomStringConvertible {
    public var description: String {
        return "(" + filmName + " " + producer + " " + String(year) + " " + String(stars) + ")"
    }
    
    var filmName, producer: String
    var year, stars: Int
        
    init(filmName: String, producer: String, year: Int, stars: Int) {
        self.filmName = filmName
        self.producer = producer
        self.year = year
        self.stars = stars
    }
        
}
