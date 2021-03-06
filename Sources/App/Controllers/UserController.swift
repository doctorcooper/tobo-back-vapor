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
        tokenProtected.post("logout", use: logout)
        
        let passwordProtected = usersRoute.grouped(UserAunthenticator())
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
        return User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .map { $0 != nil }
    }
    
    private func checkIfTokenExists(uuid: UUID, req: Request) -> EventLoopFuture<Bool> {
        let future = Token.query(on: req.db)
            .filter(\.$user.$id == uuid)
            .first()
            .map { $0 != nil }
        return future
    }
    
    private func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken()
        let userId = try user.requireID()
        
        let future = checkIfTokenExists(uuid: userId, req: req)
            .flatMap { exists in
                if exists {
                    return Token.query(on: req.db)
                        .filter(\.$user.$id == userId)
                        .delete()
                } else {
                    return req.eventLoop.future()
                }
        }.flatMap {
            return token.save(on: req.db)
        }.flatMapThrowing {
            return NewSession(token: token.value, user: user.convertToPublic())
        }
        
        return future
    }
    
    private func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self).requireID()
        return Token.query(on: req.db)
            .filter(\.$user.$id == user)
            .delete()
            .flatMapThrowing { _ -> HTTPStatus in
                return .ok
        }
    }
}
