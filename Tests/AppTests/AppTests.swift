@testable import App
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
      // 1
      let expectedName = "Alice"
      let expectedUsername = "alice"

      // 2
      var config = Config.default()
      var services = Services.default()
      var env = Environment.testing
      try App.configure(&config, &env, &services)
      let app = try Application(config: config, environment: env, services: services)
      try App.boot(app)

      // 3
      let conn = try app.newConnection(to: .psql).wait()

      // 4
      let user = User(id: nil, name: "Will", email: "mail@mail.com", passwordHash: "123")
      let savedUser = try user.save(on: conn).wait()
      //_ = try User(name: "Luke", username: "lukes").save(on: conn).wait()

      // 5
      let responder = try app.make(Responder.self)

      // 6
      let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
      let wrappedRequest = Request(http: request, using: app)

      // 7
      let response = try responder.respond(to: wrappedRequest).wait()

      // 8
      let data = response.http.body.data
      let users = try JSONDecoder().decode([User].self, from: data!)

      // 9
      XCTAssertEqual(users.count, 2)
      XCTAssertEqual(users[0].name, expectedName)
      XCTAssertEqual(users[0].username, expectedUsername)
      XCTAssertEqual(users[0].id, savedUser.id)

      // 10
      conn.close()
    }
}
