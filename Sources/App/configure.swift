import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Database
    let dbName: String = try {
        if let db = Environment.get("POSTGRES_DB") { return db }
        switch env {
        case .production:
            return "prod"
        case .development:
            return "dev"
        case .testing:
            return "test"
        default:
            throw PostgreSQLError(identifier: "env-not-supported", reason: "Environment is not supported")
        }
    }()
    let pgConfig = PostgreSQLDatabaseConfig(
        hostname: Environment.get("POSTGRES_HOST") ?? "localhost",
        port: Int(Environment.get("POSTGRES_PORT") ?? "") ?? 5429,
        username: Environment.get("POSTGRES_USER") ?? "test",
        database: dbName,
        password: Environment.get("POSTGRES_PASSWORD") ?? "test"
    )
    let pgsql = PostgreSQLDatabase(config: pgConfig)
    
    var databases = DatabasesConfig()
    databases.add(database: pgsql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: UserToken.self, database: .psql)
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)
    
    // Use fluent
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

}
