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
        
        tokenProtected.get(use: getAllTasks)
        tokenProtected.post(use: createTask)
        tokenProtected.put(":taskID", use: updateTask)
        tokenProtected.delete(":taskID", use: deleteTask)
    }

    private func getAllTasks(req: Request) throws -> EventLoopFuture<[Task]> {
        let user = try req.auth.require(User.self).requireID()
        return Task.query(on: req.db)
            .filter(\.$user.$id == user)
            .all()
    }
    
    private func createTask(req: Request) throws -> EventLoopFuture<Task> {
        let user = try req.auth.require(User.self)
        
        let taskDTO = try req.content.decode(TaskDTO.self)
        let task = try Task(title: taskDTO.title, isDone: taskDTO.isDone,
                            createdAt: nil, userID: user.requireID())
        
        return task.save(on: req.db)
            .flatMapThrowing {
                return task
        }
    }
    
    private func updateTask(req: Request) throws -> EventLoopFuture<Task> {
        let updatedTask = try req.content.decode(Task.self)
        return Task.find(req.parameters.get("taskID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { task in
                task.title = updatedTask.title
                task.isDone = updatedTask.isDone
                return task.save(on: req.db).map { task }
        }
    }
    
    private func deleteTask(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Task.find(req.parameters.get("taskID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { task in
                task.delete(on: req.db)
                    .transform(to: .noContent)
        }
    }
}
