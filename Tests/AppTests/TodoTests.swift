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
        
        let authObject = try UserTestGenerator.userToken(db: conn)
        conn.close()

        let createTodoRequestBody = CreateTodoRequestBody(title: "")
        let createTodoRequestContent = CreateTodoRequestContent(token: authObject.string, body: createTodoRequestBody)
        let todoRequest = API.Todos<Routes.Todos>.createTodo(createTodoRequestContent)

        let response = try app.getResponse(request: try todoRequest.request())
        // Response Data
        do {
            switch try todoRequest.parse(data: response.body.data) {
            case .createTodo(let responseContent):
                XCTAssertGreaterThan(responseContent.id, 0)
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating user: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }

        XCTAssert(!authObject.string.isEmpty)
    }
}
