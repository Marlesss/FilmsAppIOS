//
//  UnitTests.swift
//  UnitTests
//
//  Created by Алексей Щербаков on 30.01.2023.
//

import XCTest
@testable import filmBaseHW5

final class ServerAPITests: XCTestCase {
    func testLogin() {
        let serverAPI = ServerAPI()
        serverAPI.login(login: "admin", password: "123456", email: "admin@example.com") { result in
            if case let .failure(err) = result {
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        serverAPI.login(login: "admin", password: "123456") { result in
            if case let .failure(err) = result {
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        serverAPI.login(login: "admin", password: "1256") { result in
            if case .success(_) = result {
                XCTFail("Failed login expected. Got success.")
            }
        }
        serverAPI.login(login: "notAdmin", password: "1256") { result in
            if case .success(_) = result {
                XCTFail("Failed login expected. Got success.")
            }
        }
        usleep(1000000)
    }

    func testGetMovieById() {
        @Sendable func continueWithToken(token: String) {
            serverAPI.getMovie(id: 1, token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getMovie(id: 7, token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getMovie(id: 1234123421, token: token) { result in
                if case .success(_) = result {
                    XCTFail("Got value, error expected")
                }
            }
        }

        let serverAPI = ServerAPI()
        serverAPI.login(login: "admin", password: "123456", email: "admin@example.com") { result in
            switch result {
            case let .success(loginResponse):
                continueWithToken(token: loginResponse.token)
            case let .failure(err):
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        usleep(1000000)
    }

    func testGetMovies() {
        @Sendable func continueWithToken(token: String) {
            serverAPI.getMovies(count: 5, token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getMovies(cursor: 1, count: 5, token: token) { result in
                switch result {
                case let .success(response):
                    XCTAssertTrue(response.cursor == nil && response.movies.isEmpty, "Empty response expected, got: \(response)")
                case let .failure(err):
                    XCTFail("Got error \(err)")
                }
            }

        }

        let serverAPI = ServerAPI()
        serverAPI.login(login: "admin", password: "123456", email: "admin@example.com") { result in
            switch result {
            case let .success(loginResponse):
                continueWithToken(token: loginResponse.token)
            case let .failure(err):
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        usleep(1000000)
    }

    func testGetImage() {
        @Sendable func continueWithToken(token: String) {
            serverAPI.getImage(posterId: "aaf26adf-841b-4fce-87c2-08ca950e2fb2", token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getImage(posterId: "", token: token) { result in
                if case .success(_) = result {
                    XCTFail("Error expected")
                }
            }
        }

        let serverAPI = ServerAPI()
        serverAPI.login(login: "admin", password: "123456", email: "admin@example.com") { result in
            switch result {
            case let .success(loginResponse):
                continueWithToken(token: loginResponse.token)
            case let .failure(err):
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        usleep(1000000)
    }
    
    func testPostMovie() {
        @Sendable func continueWithToken(token: String) {
            serverAPI.postMovie(movie: ServerAPI.Movie(title: "TestFilm", director: "AbobaTester", reliseDate: 2023, rating: 2, posterId: "aaf26adf-841b-4fce-87c2-08ca950e2fb2"), token: token) { result in
                switch result {
                case let .success(movie):
                    if let id = movie.id {
                        serverAPI.deleteMovie(id: id, token: token) { result in
                            if case let .failure(err) = result {
                                XCTFail("Got error: \(err)")
                            }
                        }
                    } else {
                        XCTFail("There is no id in movie response")
                    }
                case let .failure(err):
                    XCTFail("Got error: \(err)")
                }
            }
        }

        let serverAPI = ServerAPI()
        serverAPI.login(login: "admin", password: "123456", email: "admin@example.com") { result in
            switch result {
            case let .success(loginResponse):
                continueWithToken(token: loginResponse.token)
            case let .failure(err):
                XCTFail("Success login expected. Got error: \(err)")
            }
        }
        usleep(1000000)
    }
}
