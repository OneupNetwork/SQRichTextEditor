// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQRichTextEditor",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SQRichTextEditor",
            targets: ["SQRichTextEditor"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SQRichTextEditor",
            resources: [
                .copy("Editor/index.html"),
                .copy("Editor/editor.css"),
                .copy("Editor/editor.js"),
                .copy("Editor/squire-raw.js")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
