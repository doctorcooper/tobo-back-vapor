//
//  File.swift
//  
//
//  Created by Dmitry Kupruyanov on 11.09.2020.
//

import Vapor

struct UserRegister: Content {
    let email: String
    let password: String
}

extension UserRegister: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}
