import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.register(collection: UserController())
}
