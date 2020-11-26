//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor

struct NewSession: Content {
    let token: String
    let user: User.Public
}
