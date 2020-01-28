@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Users: UserEndpoint { }
extension Routes.Login: LoginEndpoint { }

extension CreateUserResponse {
    func belongsTo(request: CreateUserRequest) -> Bool {
        request.name == name
            && request.email == email
    }
}


final class LoginTests: XCTestCase {

    private func deleteAllUsers(conn: PostgreSQLConnection) throws {
        try UserToken.query(on: conn).all().wait()
            .forEach { userToken in
                try userToken.delete(on: conn).wait()
            }
        let users = User.query(on: conn).all()
        try users.wait().forEach { user in
            try user.delete(on: conn).wait()
        }
    }
    
    func testUserLogin() throws {
        // Boot
        let app = try AppMock.defaultTestApp()
        try App.boot(app)
        let conn = try app.newConnection(to: .psql).wait()
        
        try deleteAllUsers(conn: conn)
        let userPassword = "1234"
        let user = User(id: nil, name: "William", email: "mail@mail.com", passwordHash: try BCrypt.hash(userPassword))
        let savedUser = try user.save(on: conn).wait()
        
        let loginRequest = LoginRequest(email: user.email, password: userPassword)
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
                print("")
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
        try deleteAllUsers(conn: conn)
        conn.close()

        // Request Body
        let newUserRequest = CreateUserRequest(name: "William", email: "mail@mail.com", password: "1234")
        
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
