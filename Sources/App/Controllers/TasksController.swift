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
        tokenProtected.post("list", use: createTasks)
        tokenProtected.put(":taskID", use: updateTask)
        tokenProtected.delete(":taskID", use: deleteTask)
    }

    private func getAllTasks(req: Request) throws -> EventLoopFuture<[Task]> {
        let user = try req.auth.require(User.self).requireID()
        return Task.query(on: req.db)
            .filter(\.$user.$id == user)
            .all()
    }
    
    private func createTasks(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        
        let tasksDTO = try req.content.decode([TaskDTO].self)
        return try tasksDTO
            .map { return try Task(id: $0.id,
                                   title: $0.title,
                                   isDone: $0.isDone,
                                   createdAt: $0.createdAt,
                                   userID: user.requireID()).create(on: req.db)
        }.flatten(on: req.eventLoop)
            .transform(to: .created)
    }

    private func createTask(req: Request) throws -> EventLoopFuture<Task> {
        let user = try req.auth.require(User.self)
        
        let taskDTO = try req.content.decode(TaskDTO.self)
        let task = try Task(id: taskDTO.id, title: taskDTO.title, isDone: taskDTO.isDone,
                            createdAt: taskDTO.createdAt, userID: user.requireID())
        
        return task.save(on: req.db)
            .flatMapThrowing {
                return task
        }
    }
    
    private func updateTask(req: Request) throws -> EventLoopFuture<Task> {
        let updatedTask = try req.content.decode(TaskDTO.self)
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
