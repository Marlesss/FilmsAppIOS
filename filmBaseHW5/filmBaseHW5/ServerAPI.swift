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

// TODO: add connection failed handling
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
    
    public class MovieResponse: Decodable, CustomStringConvertible {
        public var description: String {
            "\(id); \(title); \(director); \(reliseDate); \(rating); \(postedId); \(String(describing: createdAt))"
        }
        
        let id: Int
        let title: String
        let director: String
        let reliseDate: Int
        let rating: Int
        let postedId: String
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
        
        required public init(from decoder: Decoder) throws {
            let container = try (try? decoder.container(keyedBy: outCodingKeys.self).nestedContainer(keyedBy: CodingKeys.self, forKey: .movie)) ?? decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: ServerAPI.MovieResponse.CodingKeys.id)
            self.title = try container.decode(String.self, forKey: ServerAPI.MovieResponse.CodingKeys.title)
            self.director = try container.decode(String.self, forKey: ServerAPI.MovieResponse.CodingKeys.director)
            self.reliseDate = try container.decode(Int.self, forKey: ServerAPI.MovieResponse.CodingKeys.reliseDate)
            self.rating = try container.decode(Int.self, forKey: ServerAPI.MovieResponse.CodingKeys.rating)
            self.postedId = try container.decode(String.self, forKey: ServerAPI.MovieResponse.CodingKeys.posterId)
            self.createdAt = try container.decode(Int.self, forKey: ServerAPI.MovieResponse.CodingKeys.createdAt)
        }
    }
    
    public class MoviesResponse: Decodable, CustomStringConvertible {
        public var description: String {
            "[\n\(movies.map { movie in String(describing: movie) }.joined(separator: "\n"))]"
        }
        
        let cursor: Int?
        let movies: [MovieResponse]
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
        try! JSONSerialization.data(withJSONObject: data)
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
                        completion(.failure(.responseError("Unknown MIME type")))
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
                if response.mimeType == "image/jpeg" {
                    let image = UIImage(data: data)
                    if let image = image {
                        completion(.success(image))
                        return
                    }
                    completion(.failure(.responseError("Couldn't decode image")))
                    return
                }
                completion(.failure(.responseError("Unknown MIME type")))
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
    
    public func getMovie(id: Int, token: String, completion: @escaping @Sendable (Result<MovieResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/\(id)"), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func getMovies(cursor: Int? = nil, count: Int, token: String, completion: @escaping @Sendable (Result<MoviesResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/", query: ["cursor": cursor, "count": count].compactMapValues({$0}).mapValues({String($0)})), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func postImage(image: UIImage, token: String, completion: @escaping @Sendable (Result<PostImageResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/image/upload"), httpMethod: .POST, contentType: .PNG, data: image.pngData(), token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
    
    public func getImage(postedId: String, token: String, completion: @escaping @Sendable (Result<UIImage, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/image/\(postedId)"), httpMethod: .GET, token: token)
        makeTask(request: request, completion: decodeImage(completion: completion))
    }
    
    public func deleteMovie(id: Int, token: String, completion: @escaping @Sendable (Result<DeleteMovieResponse, ServerAPIError>) -> Void) {
        let request = ServerAPI.getURLRequest(url: ServerAPI.getURL(path: "/movies/\(id)"), httpMethod: .DELETE, token: token)
        makeTask(request: request, completion: decodeJson(completion: completion))
    }
}
