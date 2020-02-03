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
