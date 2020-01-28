import Vapor
@testable import App

enum AppMock {
    static func defaultTestApp() throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        try App.configure(&config, &env, &services)
        return try Application(config: config, environment: env, services: services)
    }
}

