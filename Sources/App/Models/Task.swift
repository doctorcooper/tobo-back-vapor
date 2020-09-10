//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 10.09.2020.
//

import Vapor
import Fluent

final class Task: Model {
    static let schema = "task"
    
    @ID
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "isDone")
    var isDone: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, isDone: Bool, createdAt: Date?, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.$user.id = userID
    }
}
