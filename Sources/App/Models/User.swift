//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 09.09.2020.
//

import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "users"
    
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
    
    static func create(from credentials: UserRegister) throws -> User {
        return User(email: credentials.email,
                    password: try Bcrypt.hash(credentials.password))
    }
    
    func createToken() throws -> Token {
        return try Token(value: [UInt8].random(count: 16).base64,
                         userID: requireID())
    }
}

//extension EventLoopFuture where Value: User {
//    func convertToPublic() -> EventLoopFuture<User.Public> {
//        return self.map { user in
//            return user.convertToPublic()
//        }
//    }
//}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
