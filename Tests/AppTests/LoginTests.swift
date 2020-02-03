@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Users: UserEndpoint { }
extension Routes.Login: LoginEndpoint { }

extension CreateUserResponseContent {
    func belongsTo(request: CreateUserRequestContent) -> Bool {
        request.name == name
            && request.email == email
    }
}

final class LoginTests: AppTesCase {

    private func deleteAllUsers() throws {
        let conn = try dbConnection()
        try UserToken.query(on: conn, withSoftDeleted: true).delete(force: true).wait()
        let users = User.query(on: conn).all()
        try users.wait().forEach { user in
            try user.delete(on: conn).wait()
        }
    }
    
    func testUserLogin() throws {
        try deleteAllUsers()

        let conn = try dbConnection()
        let userPassword = "1234"
        let user = User(id: nil, name: "William", email: "mail@mail.com", passwordHash: try BCrypt.hash(userPassword))
        let savedUser = try user.save(on: conn).wait()
        guard let savedUserId = savedUser.id else {
            return XCTFail("Failed creating user")
        }
        let loginRequest = LoginRequestContent(email: user.email, password: userPassword)
        let loginEndpoint = API.Login<Routes.Login>.login(loginRequest)
        // Get Response
        let response = try app.getResponse(request: try loginEndpoint.request())
        // Response Data
        guard let responseData = response.body.data else {
            return XCTFail("Data is nil")
        }
        
        do {
            switch try loginEndpoint.parse(data: responseData) {
            case .login(let loginResponse):
                XCTAssertEqual(loginResponse.userID, savedUserId)
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating user: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: responseData, encoding: .utf8)!)")
        }
    }
    
    func testUserCreation() throws {
        // Boot
        let app = try AppMock.defaultTestApp()
        try App.boot(app)

        // Connect to DB
        let conn = try app.newConnection(to: .psql).wait()
        try deleteAllUsers()
        conn.close()

        // Request Body
        let newUserRequest = CreateUserRequestContent(name: "William", email: "mail@mail.com", password: "1234")
        
        // Enpoint Request
        let createUserEndpoint = API.User<Routes.Users>.createUser(newUserRequest)
        
        // Get Response
        let response = try app.getResponse(request: try createUserEndpoint.request())

        // Response Data
        guard let responseData = response.body.data else {
            return XCTFail("Data is nil")
        }
        do {
            switch try createUserEndpoint.parse(data: responseData) {
            case .createUser(let createUserResponse):
                XCTAssertTrue(createUserResponse.belongsTo(request: newUserRequest))
            }
        } catch let responseError as ResponseError {
           XCTFail("Failed creating user: \(responseError.reason)")
        } catch {
           XCTFail("Failed decoding data: \(String(data: responseData, encoding: .utf8)!)")
        }
    }
}
