@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Todos: TodosEndpoint { }

final class TodoTests: XCTestCase {

    private func deleteAllTodos(conn: PostgreSQLConnection) throws {
        //try Todo.query(on: conn, withSoftDeleted: true).delete(force: true).wait()
        let todos = Todo.query(on: conn).all()
        try todos.wait().forEach { todo in
            try todo.delete(on: conn).wait()
        }
    }

    func testTodoCreation() throws {
        // Boot
        let app = try AppMock.defaultTestApp()
        try App.boot(app)

        // Connect to DB
        let conn = try app.newConnection(to: .psql).wait()
        try deleteAllTodos(conn: conn)
        
        let email = "mail@mail.com"
        let password = "1234"
        let createUserRequestContent = App.CreateUserRequestContent(name: "William",
                                                                    email: email,
                                                                    password: password,
                                                                    verifyPassword: password)
        let createUserUseCase = CreateUserUseCase(user: createUserRequestContent, db: conn)
        let _ = try? createUserUseCase.createUser().wait()
        
        guard let userResult = try? User.query(on: conn).filter(\.email == email).all().wait().first, let user = userResult else {
            return XCTFail("Failed creating user")
        }
        
        let authenticateUseCase = AuthenticateUserUseCase(user: user, db: conn)
        let auth = try? authenticateUseCase.authenticateUser().wait()
        guard let authObject = auth, let authId = authObject.id else {
            return XCTFail("Failed authenticating")
        }
        
        let createTodoRequestBody = CreateTodoRequestBody(title: "")
        let createTodoRequestContent = CreateTodoRequestContent(token: authObject.string, body: createTodoRequestBody)
        let todoRequest = API.Todos<Routes.Todos>.createTodo(createTodoRequestContent)
        let response = try app.getResponse(request: try todoRequest.request())
        // Response Data
        guard let responseData = response.body.data else {
            return XCTFail("Data is nil")
        }
        do {
            switch try todoRequest.parse(data: responseData) {
            case .createTodo(let responseContent):
                print("Here")
            }
        } catch let responseError as ResponseError {
                  XCTFail("Failed creating user: \(responseError.reason)")
               } catch {
                  XCTFail("Failed decoding data: \(String(data: responseData, encoding: .utf8)!)")
               }
        
        conn.close()
        
        
        XCTAssert(!authObject.string.isEmpty)

        // Request Body
        /*let newUserRequest = CreateUserRequestContent(name: "William", email: "mail@mail.com", password: "1234")
        
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
        }*/
    }
}
