//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 09.09.2020.
//

import Vapor
import Fluent

final class User: Model, Content, Authenticatable {
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

struct UserAunthenticator: CredentialsAuthenticator {
    
    typealias Credentials = UserRegister
    
    func authenticate(credentials: UserRegister, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db)
            .filter(\.$email == credentials.email)
            .first()
            .flatMapThrowing {
                if let user = $0, try Bcrypt.verify(credentials.password,
                                                    created: user.password) {
                    request.auth.login(user)
                }
        }
    }
}
