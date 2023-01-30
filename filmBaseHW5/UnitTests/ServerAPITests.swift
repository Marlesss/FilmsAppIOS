//
//  UnitTests.swift
//  UnitTests
//
//  Created by Алексей Щербаков on 30.01.2023.
//

import XCTest
@testable import filmBaseHW5

final class ServerAPITests: XCTestCase {
    
    //    override func setUpWithError() throws {
    //        // Put setup code here. This method is called before the invocation of each test method in the class.
    //    }
    
    //    override func tearDownWithError() throws {
    //        // Put teardown code here. This method is called after the invocation of each test method in the class.
    //    }
    
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
            serverAPI.getMovie(id: 2, token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getMovie(id: 5, token: token) { result in
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
            serverAPI.getImage(postedId: "a923245a-5d80-4c1f-95a2-5fc653235711", token: token) { result in
                if case let .failure(err) = result {
                    XCTFail("Got error \(err)")
                }
            }
            serverAPI.getImage(postedId: "", token: token) { result in
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
    
    
    
    //        func testPerformanceExample() throws {
    //            // This is an example of a performance test case.
    //            measure {
    //                // Put the code you want to measure the time of here.
    //            }
    //        }
    
}
