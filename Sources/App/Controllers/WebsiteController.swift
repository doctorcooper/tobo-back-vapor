//
//  File.swift
//  
//
//  Created by Dmitry Kupriyanov on 23.09.2020.
//

import Leaf
import Vapor

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
    }
    
    private func index(req: Request) throws -> EventLoopFuture<View> {
        return req.view.render("index")
    }
}
