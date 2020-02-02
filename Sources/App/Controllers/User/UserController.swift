import Crypto
import Vapor
import FluentPostgreSQL

struct AuthenticateUserUseCase {
    let user: User
    let db: DatabaseConnectable
    func authenticateUser() throws -> EventLoopFuture<UserToken> {
        // create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        // save and return token
        return token.save(on: db)
    }
}

struct CreateUserUseCase {
    let user: CreateUserRequestContent
    let db: DatabaseConnectable

    func createUser() throws -> Future<User> {
        // verify that passwords match 
        guard user.password == user.verifyPassword else {
            throw Abort(.badRequest, reason: "Password and verification must match.")
        }
        
        // hash user's password using BCrypt
        let hash = try BCrypt.hash(user.password)
        // save new user
        return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
            .save(on: db)
    }
}

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        let useCase = AuthenticateUserUseCase(user: user, db: req)
        return try useCase.authenticateUser()
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<CreateUserResponseContent> {
        // decode request content
        return try req.content.decode(CreateUserRequestContent.self).flatMap { user -> Future<User> in
            let useCase = CreateUserUseCase(user: user,
                                            db: req)
            return try useCase.createUser()
        }.map { user in
            // map to public user response (omits password hash)
            return try CreateUserResponseContent(id: user.requireID(), name: user.name, email: user.email)
        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequestContent: Content {
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct CreateUserResponseContent: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
}
