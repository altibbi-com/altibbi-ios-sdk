// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AltibbiTelehealth",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AltibbiTelehealth",
            targets: ["AltibbiTelehealth"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pusher/pusher-websocket-swift.git",
            exact: "10.1.6"
        ),
        .package(
            url: "https://github.com/sendbird/sendbird-chat-sdk-ios.git",
            exact: "4.19.2"
        )
    ],
    targets: [
        .target(
            name: "AltibbiTelehealth",
            dependencies: [
                .product(name: "PusherSwift", package: "pusher-websocket-swift"),
                .product(name: "SendbirdChatSDK", package: "sendbird-chat-sdk-ios")
            ],
            path: "AltibbiTelehealth/Classes"
        )
    ]
)


