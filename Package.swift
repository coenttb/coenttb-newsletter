// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbNewsletter: Self = "CoenttbNewsletter"
    static let coenttbNewsletterFluent: Self = "CoenttbNewsletterFluent"
}

extension Target.Dependency {
    static var coenttbNewsletter: Self { .target(name: .coenttbNewsletter) }
    static var coenttbNewsletterFluent: Self { .target(name: .coenttbNewsletterFluent) }
}

extension Target.Dependency {
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    
}
extension Target.Dependency {
    static var coenttbWeb: Self { .product(name: "CoenttbWeb", package: "coenttb-web") }
    static var codable: Self { .product(name: "MacroCodableKit", package: "macro-codable-kit") }
    static var vapor: Self { .product(name: "Vapor", package: "Vapor") }
    static var fluent: Self { .product(name: "Fluent", package: "fluent") }
    static var rateLimiter: Self { .product(name: "RateLimiter", package: "coenttb-utils") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
}

let package = Package(
    name: "coenttb-newsletter",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbNewsletter, targets: [.coenttbNewsletter]),
        .library(name: .coenttbNewsletterFluent, targets: [.coenttbNewsletterFluent]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-mailgun.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-utils.git", branch: "main"),
        .package(url: "https://github.com/coenttb/macro-codable-kit.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
    ],
    targets: [
        .target(
            name: .coenttbNewsletter,
            dependencies: [
                .dependenciesMacros,
                .codable,
                .coenttbWeb,
                .vapor,
                .fluent,
                .rateLimiter,
                .mailgun,
            ]
        ),
        .target(
            name: .coenttbNewsletterFluent,
            dependencies: [
                .codable,
                .coenttbNewsletter,
                .coenttbWeb,
                .fluent,
                .vapor,
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
