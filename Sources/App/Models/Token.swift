//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 10.09.2020.
//

import Vapor
import Fluent

final class Token: Model, Content {
    static let schema = "tokens"
    
    @ID
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension Token: ModelTokenAuthenticatable {
    static var valueKey = \Token.$value
    static var userKey = \Token.$user
    
    var isValid: Bool {
        return true
    }
}
