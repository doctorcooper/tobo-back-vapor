//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 10.09.2020.
//

import Vapor
import Fluent

final class Task: Model, Content {
    static let schema = "tasks"
    
    @ID
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "is_done")
    var isDone: Bool
    
    @Field(key: "created_at")
    var createdAt: Date?
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, isDone: Bool, createdAt: Date?, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
        self.$user.id = userID
    }
}

final class TaskDTO: Content {
    let id: UUID
    let title: String
    let createdAt: Date
    let isDone: Bool
}
