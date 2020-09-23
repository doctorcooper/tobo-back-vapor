import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: TasksController())
    try app.register(collection: WebsiteController())
}
