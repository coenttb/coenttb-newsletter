//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Foundation
import EmailAddress

public struct Request: Codable, Hashable, Sendable {
    public let email: String
    
    public init(email: String = "") {
        self.email = email
    }
    
    public enum CodingKeys: String, CodingKey {
        case email
    }
}

extension Request {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}
