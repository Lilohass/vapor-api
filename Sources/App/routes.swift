import Crypto
import Vapor

enum Routes {
    enum Users {
        static let users: String = "users"
        static var url: URL { URL(string: users)! }
    }
    enum Login {
        static let login: String = "login"
    }
    enum Todos {
        static let todos: String = "todos"
    }
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // public routes
    let userController = UserController()
    router.post(Routes.Users.users,
                use: userController.create)

    // basic / password auth protected routes
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post(Routes.Login.login,
               use: userController.login)

    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let todoController = TodoController()
    bearer.get(Routes.Todos.todos, use: todoController.index)
    bearer.post(Routes.Todos.todos, use: todoController.create)
    bearer.delete(Routes.Todos.todos, Todo.parameter, use: todoController.delete)
}
