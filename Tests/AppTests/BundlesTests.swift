@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

//extension Routes.Todos: TodosEndpoint { }
extension Routes.Bundle: BundlesEndpoint { }

final class BundlesTests: XCTestCase {

//    private func deleteAllTodos(conn: PostgreSQLConnection) throws {
//        //try Todo.query(on: conn, withSoftDeleted: true).delete(force: true).wait()
//        let todos = Todo.query(on: conn).all()
//        try todos.wait().forEach { todo in
//            try todo.delete(on: conn).wait()
//        }
//    }
    

    func testBundleUpload() throws {
        // Boot
        let app = try AppMock.defaultTestApp()
        try App.boot(app)

        // Connect to DB
        let conn = try app.newConnection(to: .psql).wait()
        //try deleteAllTodos(conn: conn)
        
        let authObject = try UserTestGenerator.userToken(db: conn)
        conn.close()

        typealias BundlesAPI = API.Bundles<Routes.Bundle>
        let brands = BundlesAPI.Brand(name: "New brand")
        let bundleRequestBody = BundlesAPI.CreateRequestBody(brands: [brands])
        let uploadBundleRequestContent = BundlesAPI.CreateRequestContent(
            token: authObject.string,
            body: bundleRequestBody
        )
        let uploadRequest = API.Bundles<Routes.Bundle>.uploadBundle(uploadBundleRequestContent)
        let response = try app.getResponse(request: try uploadRequest.request())

        // Response Data
        do {
            switch try uploadRequest.parse(data: response.body.data) {
            case .uploadBundle(let responseContent):
                XCTAssertFalse(responseContent.brands.error)
            }
        } catch let responseError as ResponseError {
            let error = String(data: try JSONEncoder().encode(responseError), encoding: .utf8)!
            XCTFail("Failed creating user: \(error)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }

        XCTAssert(!authObject.string.isEmpty)
        
        
        /*let createTodoRequestBody = CreateTodoRequestBody(title: "")
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

        XCTAssert(!authObject.string.isEmpty)*/
    }
}
