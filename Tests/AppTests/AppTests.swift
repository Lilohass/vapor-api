@testable import App
//import App
import Vapor
import XCTest
import FluentPostgreSQL

final class AppTests: XCTestCase {
    func testNothing() throws {
        // Add your tests here
        XCTAssert(true)
    }

    static let allTests = [
        ("testNothing", testNothing)
    ]
    
    func testUsersCanBeRetrievedFromAPI() throws {
        // Boot
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)

        // Connect to DB
        let conn = try app.newConnection(to: .psql).wait()

        // Delete all Todos
        let some = Todo.query(on: conn).all()
        try some.wait().forEach { todo in
            try todo.delete(on: conn).wait()
        }
        
        // Add a new Todo
        let expectedName = "Alice"
        let todo = Todo(id: nil, title: expectedName)
        let savedTodo = try todo.save(on: conn).wait()

        // Create Request
        let request = HTTPRequest(method: .GET, url: URL(string: "/todos")!)
        let wrappedRequest = Request(http: request, using: app)

        // Response
        let responder = try app.make(Responder.self)
        let response = try responder.respond(to: wrappedRequest).wait()

        // Response Data
        let data = response.http.body.data
        let todos = try JSONDecoder().decode([Todo].self, from: data!)

        // Assertion
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos[0].title, expectedName)
        XCTAssertEqual(todos[0].id, savedTodo.id)

        // Close
        conn.close()
    }
}
