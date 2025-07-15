// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbNewsletter: Self = "Coenttb Newsletter"
    static let coenttbNewsletterLive: Self = "Coenttb Newsletter Live"
    static let coenttbNewsletterFluent: Self = "Coenttb Newsletter Fluent"
}

extension Target.Dependency {
    static var coenttbNewsletter: Self { .target(name: .coenttbNewsletter) }
    static var coenttbNewsletterLive: Self { .target(name: .coenttbNewsletterLive) }
    static var coenttbNewsletterFluent: Self { .target(name: .coenttbNewsletterFluent) }
}

extension Target.Dependency {
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var coenttbVapor: Self { .product(name: "Coenttb Vapor", package: "coenttb-server-vapor") }
    static var coenttbFluent: Self { .product(name: "Coenttb Fluent", package: "coenttb-server-vapor") }
    static var coenttbDatabase: Self { .product(name: "Coenttb Database", package: "coenttb-server") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var rateLimiter: Self { .product(name: "RateLimiter", package: "coenttb-utils") }
}

let package = Package(
    name: "coenttb-newsletter",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbNewsletter, targets: [.coenttbNewsletter]),
        .library(name: .coenttbNewsletterLive, targets: [.coenttbNewsletterLive]),
        .library(name: .coenttbNewsletterFluent, targets: [.coenttbNewsletterFluent])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server-vapor.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-mailgun.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-utils.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: .coenttbNewsletter,
            dependencies: [
                .coenttbWeb,
                .dependenciesMacros,
                .rateLimiter
            ]
        ),
        .target(
            name: .coenttbNewsletterLive,
            dependencies: [
                .coenttbWeb,
                .coenttbDatabase,
                .coenttbVapor,
                .coenttbNewsletter,
                .rateLimiter,
                .mailgun
            ]
        ),
        .target(
            name: .coenttbNewsletterFluent,
            dependencies: [
                .coenttbWeb,
                .coenttbDatabase,
                .coenttbVapor,
                .coenttbNewsletter,
                .coenttbNewsletterLive,
                .coenttbFluent
            ]
        ),
        .testTarget(
            name: .coenttbNewsletter + " Tests",
            dependencies: [
                .coenttbNewsletter,
                .dependenciesTestSupport
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
