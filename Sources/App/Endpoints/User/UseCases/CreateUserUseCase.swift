import Crypto
import Vapor
import FluentPostgreSQL

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
