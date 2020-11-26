//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor
import Fluent

struct CreateTokens: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema)
            .id()
            .field("value", .string, .required)
            .unique(on: "value")
            .field("user_id", .uuid, .references(User.schema, "id"))
            .unique(on: "user_id")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}
