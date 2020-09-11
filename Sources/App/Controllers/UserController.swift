//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("register", use: createUser)
        
        let tokenProtected = usersRoute.grouped(Token.authenticator())
        tokenProtected.get("me", use: getCurrentUser)
        
        let passwordProtected = usersRoute.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
    }
    
    private func createUser(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserRegister.validate(content: req)
        let userSignup = try req.content.decode(UserRegister.self)
        let user = try User.create(from: userSignup)
        var token: Token!
        return checkIfUserExists(userSignup.email, req: req)
            .flatMap { exists in
                if exists {
                    return req.eventLoop.future(error: Abort(.conflict))
                } else {
                    return user.save(on: req.db)
                }
            }.flatMap {
                guard let newToken = try? user.createToken() else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                }
                token = newToken
                return token.save(on: req.db)
            }.flatMapThrowing {
                NewSession(token: token.value, user: user.convertToPublic())
            }
    }
    
    private func getCurrentUser(req: Request) throws -> User.Public {
        return try req.auth.require(User.self).convertToPublic()
    }
    
    private func checkIfUserExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .map { $0 != nil }
    }
    
    private func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken()
        
        return token.save(on: req.db)
            .flatMapThrowing { _ in
                return NewSession(token: token.value, user: user.convertToPublic())
        }
    }
}
