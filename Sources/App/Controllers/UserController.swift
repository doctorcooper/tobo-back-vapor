//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("register", use: createUser)
    }
    
    private func createUser(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserRegister.validate(content: req)
        let userSignup = try req.content.decode(UserRegister.self)
        let user = try User.create(from: userSignup)
        var token: Token!
            
        return user.save(on: req.db)
        .flatMap {
            guard let newToken = try? user.createToken() else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NewSession(token: token.value, user: user.convertToPublic())
        }
    }
}
