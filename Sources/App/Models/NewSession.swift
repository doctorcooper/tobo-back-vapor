//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor

struct NewSecction: Content {
    let token: Token
    let user: User.Public
}
