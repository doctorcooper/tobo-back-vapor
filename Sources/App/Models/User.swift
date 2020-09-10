//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 09.09.2020.
//

import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "user"
    
    @ID
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
    
    final class Public: Content {
        var id: UUID?
        var email: String
        
        init(id: UUID?, email: String) {
            self.id = id
            self.email = email
        }
    }
    
    func convertToPublic() -> Public {
        return Public(id: id, email: email)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}
