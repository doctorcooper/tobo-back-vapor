//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor
import Fluent

struct TasksController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let taskRoute = routes.grouped("task")
        let tokenProtected = taskRoute.grouped(Token.authenticator())
        
        tokenProtected.get("/", use: getAllTasks)
    }

    private func getAllTasks(req: Request) throws -> EventLoopFuture<[Task]> {
        let user = try req.auth.require(User.self).requireID()
        return Task.query(on: req.db)
            .filter(\.$user.$id == user)
            .all()
    }
    
    private func createTask(req: Request) throws -> EventLoopFuture<Task> {
        let userID = try req.auth.require(User.self).requireID()
        
        let taskDTO = try req.content.decode(TaskDTO.self)
        let task = Task(title: taskDTO.title, isDone: taskDTO.isDone, createdAt: nil, userID: userID)
        
        return task.save(on: req.db).flatMapThrowing {
            return task
        }
    }
    
}
