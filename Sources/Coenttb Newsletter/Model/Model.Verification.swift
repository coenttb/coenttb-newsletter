//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Foundation
import EmailAddress

public struct Verification: Codable, Hashable, Sendable {
    public let token: String
    public let email: String
    
    public init(
        token: String = "",
        email: String = ""
    ) {
        self.token = token
        self.email = email
    }
    
    public enum CodingKeys: String, CodingKey {
        case token
        case email
    }
}

extension Verification {
    public init(
        token: String,
        email: EmailAddress
    ){
        self.token = token
        self.email = email.rawValue
    }
}
