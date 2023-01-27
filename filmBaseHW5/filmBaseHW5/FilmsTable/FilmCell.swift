import UIKit


// TODO: Add image displaying
class FilmCell: UITableViewCell {
    private var filmData: FilmData?
    @IBOutlet var filmImageView: UIImageView!
    @IBOutlet var filmName: UILabel!
    @IBOutlet var producer: UILabel!
    @IBOutlet var year: UILabel!
    @IBOutlet var stars: StarsRow!
    
    public func setup(_ film: FilmData) {
        self.filmData = film
        filmImageView.image = film.image
        filmName.text = film.filmName
        producer.text = film.producer
        year.text = "Год: " + String(film.year)
        stars.setMark(mark: film.stars)
    }
    
    @IBAction func starsChoosed() {
        guard let mark = stars.getData() else {
            return
        }
        filmData?.stars = mark
    }
}
