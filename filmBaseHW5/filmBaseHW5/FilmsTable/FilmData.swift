import UIKit
import Dispatch

public class FilmData: CustomStringConvertible {
    public var description: String {
        return "(" + filmName + " " + producer + " " + String(year) + " " + String(stars) + ")"
    }
    public let filmName, producer: String
    public let year: Int
    public let stars: Int
    public let image: UIImage
    
    init(image: UIImage, filmName: String, producer: String, year: Int, stars: Int) {
        self.image = image
        self.filmName = filmName
        self.producer = producer
        self.year = year
        self.stars = stars
    }
}

extension ServerAPI.Movie {
    static public func make(from film: FilmData, token: String, completion: @escaping @Sendable (Result<ServerAPI.Movie, ServerAPIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            ViewController.loadImageAPI.postImage(image: film.image, token: token) { postResult in
                switch postResult {
                case let .success(postResponse):
                    let movie = ServerAPI.Movie(title: film.filmName, director: film.producer, reliseDate: film.year, rating: film.stars, posterId: postResponse.posterId)
                    ViewController.serverAPI.postMovie(movie: movie, token: token) { movieResult in
                        switch movieResult {
                        case let .success(movieResponse):
                            completion(.success(movieResponse))
                        case let .failure(movieError):
                            completion(.failure(movieError))
                        }
                    }
                case let .failure(postError):
                    completion(.failure(postError))
                }
            }
        }
    }
}
