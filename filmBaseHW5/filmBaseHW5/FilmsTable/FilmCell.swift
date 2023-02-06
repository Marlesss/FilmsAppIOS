import UIKit


// TODO: caching images
// TODO: make tasks cancellable (or not?)
// TODO: fix lags
public class FilmCell: UITableViewCell {
    private var movie: ServerAPI.Movie?
    @IBOutlet var filmImageView: UIImageView!
    @IBOutlet var filmName: UILabel!
    @IBOutlet var producer: UILabel!
    @IBOutlet var year: UILabel!
    @IBOutlet var stars: StarsRow!
    
    public func setup(_ movie: ServerAPI.Movie, token: String) {
        self.movie = movie
        filmImageView.image = nil
        filmName.text = movie.title
        producer.text = movie.director
        year.text = "Год: " + String(movie.reliseDate)
        stars.setMark(mark: movie.rating)
        loadImage(movie, token)
    }
    
    @IBAction func starsChoosed() {
        //        guard let mark = stars.getData() else {
        //            return
        //        }
        //        filmData?.stars = mark
    }
    
    private func loadImage(_ movie: ServerAPI.Movie, _ token: String) {
        print("start loading \(movie.title)")
        DispatchQueue.global(qos: .userInitiated).async {
            ViewController.loadImageAPI.getImage(posterId: movie.posterId, token: token) { result in
                switch result {
                case let .success(image):
                    DispatchQueue.main.sync {
                        print("Got image for \(movie.title)")
                        self.setImage(movie, image)
                    }
                case let .failure(err):
                    print("Got error \(err) for \(movie.title)")
                }
            }
        }
    }
    
    private func setImage(_ movie: ServerAPI.Movie, _ image: UIImage) {
        guard self.movie === movie else {return}
        filmImageView.image = image
        // TODO: crash
    }
}
