//
//  ServerAPI.swift
//  filmBaseHW5
//
//  Created by Алексей Щербаков on 29.01.2023.
//

import Foundation
import UIKit

public enum ServerAPIError: Error {
    case responseError(String)
    case taskError(String)
    case unknownError
}

// TODO: recognize jpeg and png images
// TODO: compress jpeg photos
public class ServerAPI {
    public enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case DELETE = "DELETE"
    }
    
    public enum ContentType: String {
        case JSON = "application/json; charset=UTF-8"
        case PNG = "image/png"
    }
    
    public class ResponseData<T: Decodable>: Decodable {
        let error: Int
        let message: String
        let data: T?
    }
    
    public class LoginResponse: Decodable {
        let token: String
        let user: [String:String]
    }
    
    public class Movie: Codable, CustomStringConvertible {
        public var description: String {
            "\(id ?? -1); \(title); \(director); \(reliseDate); \(rating); \(posterId); \(String(describing: createdAt))"
        }
        
        let id: Int?
        let title: String
        let director: String
        let reliseDate: Int
        let rating: Int
        let posterId: String
        let createdAt: Int?
        
        enum CodingKeys: CodingKey {
            case id
            case title
            case director
            case reliseDate
            case rating
            case posterId
            case createdAt
        }
        
        enum outCodingKeys: CodingKey {
            case movie
        }
        
        public init(id: Int? = nil, title: String, director: String, reliseDate: Int, rating: Int, posterId: String, createdAt: Int? = nil) {
            self.id = id
            self.title = title
            self.director = director
            self.reliseDate = reliseDate
            self.rating = rating
            self.posterId = posterId
            self.createdAt = createdAt
        }
        
        required public init(from decoder: Decoder) throws {
            let container = try (try? decoder.container(keyedBy: outCodingKeys.self).nestedContainer(keyedBy: CodingKeys.self, forKey: .movie)) ?? decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: ServerAPI.Movie.CodingKeys.id)
            self.title = try container.decode(String.self, forKey: ServerAPI.Movie.CodingKeys.title)
            self.director = try container.decode(String.self, forKey: ServerAPI.Movie.CodingKeys.director)
            self.reliseDate = try container.decode(Int.self, forKey: ServerAPI.Movie.CodingKeys.reliseDate)
            self.rating = try container.decode(Int.self, forKey: ServerAPI.Movie.CodingKeys.rating)
            self.posterId = try container.decode(String.self, forKey: ServerAPI.Movie.CodingKeys.posterId)
            self.createdAt = try container.decode(Int.self, forKey: ServerAPI.Movie.CodingKeys.createdAt)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<ServerAPI.Movie.CodingKeys> = encoder.container(keyedBy: ServerAPI.Movie.CodingKeys.self)
            try container.encodeIfPresent(self.id, forKey: ServerAPI.Movie.CodingKeys.id)
            try container.encode(self.title, forKey: ServerAPI.Movie.CodingKeys.title)
            try container.encode(self.director, forKey: ServerAPI.Movie.CodingKeys.director)
            try container.encode(self.reliseDate, forKey: ServerAPI.Movie.CodingKeys.reliseDate)
            try container.encode(self.rating, forKey: ServerAPI.Movie.CodingKeys.rating)
            try container.encode(self.posterId, forKey: ServerAPI.Movie.CodingKeys.posterId)
            try container.encode(self.createdAt, forKey: ServerAPI.Movie.CodingKeys.createdAt)
        }
    }
    
    public class MoviesResponse: Decodable, CustomStringConvertible {
        public var description: String {
            "[\n\(movies.map { movie in String(describing: movie) }.joined(separator: "\n"))]"
        }
        
        let cursor: Int?
        let movies: [Movie]
    }
    
    public class PostImageResponse: Decodable {
        let posterId: String
    }
    
    public class DeleteMovieResponse: Decodable {
        let deleted: Int
    }
    
    static private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    static private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    static private let urlScheme = "http"
    static private let urlHost = "127.0.0.1"
    static private let urlPort = 8080
    
    private let session: URLSession
    
    init() {
        session = URLSession.shared
    }
    
    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    static public func getURL(path: String, query: [String:String]? = nil) -> URL? {
        var urlConstructor = URLComponents()
        urlConstructor.scheme = urlScheme
        urlConstructor.host = urlHost
        urlConstructor.port = urlPort
        urlConstructor.path = path
        urlConstructor.queryItems = query?.map { (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        }
        return urlConstructor.url
    }
    
    static public func JSONEncode(data: Codable) -> Data {
        try! encoder.encode(data)
    }
    
    static public func getURLRequest(url: URL?, httpMethod: HTTPMethod, contentType: ContentType? = nil, data: Data? = nil, token: String? = nil) -> URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod.rawValue
        if let contentType = contentType, let data = data {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-type")
            request.httpBody = data
        }
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func makeTask(request: URLRequest, completion: @escaping @Sendable (Result<(Data, URLResponse), ServerAPIError>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            guard let response = response else {
                completion(.failure(.responseError("No response")))
                return
            }
            if let data = data {
                completion(.success((data, response)))
                return
            }
            if let error = error {
                completion(.failure(.taskError(error.localizedDescription)))
                return
            }
            completion(.failure(.unknownError))
        }
        task.resume()
    }
    
    @Sendable
    private func decodeJson<T: Decodable>(completion: @escaping @Sendable (Result<T, ServerAPIError>) -> Void) -> (@Sendable (Result<(Data, URLResponse), ServerAPIError>) -> Void) {
        @Sendable func handleData(result: Result<(Data, URLResponse), ServerAPIError>){
            switch result {
            case let .failure(err):
                completion(.failure(err))
                return
            case let .success((data, response)):
                do {
                    if response.mimeType == "application/json" {
                        let result = try ServerAPI.decoder.decode(ResponseData<T>.self, from: data)
                        if result.error == 0 {
                            completion(.success(result.data!))
                            return
                        }
                        completion(.failure(.responseError(result.message)))
                    } else {
                        if response.mimeType == "text/plain" {
                            print(String(data: data, encoding: .utf8))
                        }
                        completion(.failure(.responseError("Unknown MIME type (Got \(response.mimeType)")))
                    }
                } catch {
                    completion(.failure(.responseError("Couldn't decode response (\(error)")))
                    return
                }
            }
        }
        return handleData
    }
    
    @Sendable
    private func decodeImage(completion: @escaping @Sendable (Result<UIImage, ServerAPIError>) -> Void) -> (@Sendable (Result<(Data, URLResponse), ServerAPIError>) -> Void) {
        @Sendable func handleData(result: Result<(Data, URLResponse), ServerAPIError>) {
            switch result {
            case let .failure(err):
                completion(.failure(err))
                return
            case let .success((data, response)):
                if response.mimeType == "image/jpeg" || response.mimeType == "image/png" {
                    let image = UIImage(data: data)
                    if let image = image {
                        completion(.success(image))
                        return
                    }
                    completion(.failure(.responseError("Couldn't decode image")))
                    return
                }
                //                var message: String?
                //                if response.mimeType == "text/plain" {
                //                    message = try! ServerAPI.decoder.decode(String.self, from: data)
                //                }
                completion(.failure(.responseError("Unknown MIME type (Got \(response.mimeType))")))
            }
        }
        return handleData
    }
    
    public func register(login: String, password: String, email: String, completion: @escaping @Sendable (Result<String, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/auth/register"), httpMethod: .POST, contentType: .JSON, data: ServerAPI.JSONEncode(data: ["login": login, "password": password, "email": email]))
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func login(login: String, password: String, email: String? = nil, completion: @escaping @Sendable (Result<LoginResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/auth/login"), httpMethod: .POST, contentType: .JSON, data: ServerAPI.JSONEncode(data: ["login": login, "password": password, "email": email].compactMapValues({$0})))
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func getMovie(id: Int, token: String, completion: @escaping @Sendable (Result<Movie, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/\(id)"), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func getMovies(cursor: Int? = nil, count: Int, token: String, completion: @escaping @Sendable (Result<MoviesResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/", query: ["cursor": cursor, "count": count].compactMapValues({$0}).mapValues({String($0)})), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func postImage(image: UIImage, token: String, completion: @escaping @Sendable (Result<PostImageResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/image/upload"), httpMethod: .POST, contentType: .PNG, data: image.unrotatedPngData(), token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func getImage(posterId: String, token: String, completion: @escaping @Sendable (Result<UIImage, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/image/\(posterId)"), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeImage(completion: completion))
    }
    
    public func deleteMovie(id: Int, token: String, completion: @escaping @Sendable (Result<DeleteMovieResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/\(id)"), httpMethod: .DELETE, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func postMovie(movie: Movie, token: String, completion: @escaping @Sendable (Result<Movie, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/"), httpMethod: .POST, contentType: .JSON, data: ServerAPI.JSONEncode(data: ["movie":movie]), token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
}

extension UIImage {
    func unrotatedPngData() -> Data? {
        if imageOrientation == .up {
            return pngData()
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(at: .zero)
        }.pngData()
    }
}
