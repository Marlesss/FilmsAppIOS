import UIKit

// cursor=null, cnt = CONST
// while prevCursor != null do cursor=prevCursor, cnt = CONST

public class FilmData: CustomStringConvertible {
    public var description: String {
        return "(" + filmName + " " + producer + " " + String(year) + " " + String(stars) + ")"
    }
    
    public let filmName, producer: String
    public let year: Int
    public var stars: Int
    public let image: UIImage
    
    init(image: UIImage, filmName: String, producer: String, year: Int, stars: Int) {
        self.image = image
        self.filmName = filmName
        self.producer = producer
        self.year = year
        self.stars = stars
    }
}
