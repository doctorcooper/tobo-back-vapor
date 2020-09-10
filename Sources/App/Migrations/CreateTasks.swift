//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor
import Fluent

struct CreateTasks: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Task.schema)
            .id()
            .field("title", .string, .required)
            .field("is_done", .bool, .required)
            .field("created_at", .datetime, .required)
            .field("user_id", .uuid, .references(User.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Task.schema).delete()
    }
}
