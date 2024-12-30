//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 19/12/2024.
//

import Foundation
import Coenttb_Vapor

extension HTTPHeaders.Name {
    public static let xRateLimitLimit: Self = "X-RateLimit-Limit"
    public static let xRateLimitRemaining: Self = "X-RateLimit-Remaining"
    public static let xRateLimitReset: Self = "X-RateLimit-Reset"
    public static let xEmailRateLimitRemaining: Self = "X-Email-RateLimit-Remaining"
    public static let xIPRateLimitRemaining: Self = "X-IP-RateLimit-Remaining"
    public static let xRateLimitSource: Self = "X-RateLimit-Source"
}
