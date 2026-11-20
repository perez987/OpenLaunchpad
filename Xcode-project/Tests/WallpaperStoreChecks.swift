import Foundation

@main
struct WallpaperStoreChecks {
    static func main() throws {
        let id = "F6A2B038-270A-4C8E-83EA-A7F68457413E"
        let url = URL(fileURLWithPath: "/tmp/desktop image.png")
        func choice(_ provider: String, _ configuration: [String: Any]) throws -> [String: Any] {
            [
                "Provider": provider,
                "Configuration": try PropertyListSerialization.data(
                    fromPropertyList: configuration, format: .binary, options: 0
                ),
            ]
        }
        func scope(_ selected: [String: Any], _ date: TimeInterval, linked: Bool = false) -> [String: Any] {
            [
                "Type": linked ? "linked" : "individual",
                linked ? "Linked" : "Desktop": [
                    "LastUse": Date(timeIntervalSince1970: date),
                    "Content": ["Choices": [selected]],
                ],
            ]
        }
        let image = try choice("com.apple.wallpaper.choice.image", [
            "type": "imageFile", "url": ["relative": url.absoluteString],
        ])
        let aerial = try choice("com.apple.wallpaper.choice.aerials", ["assetID": id])
        let global = scope(image, 1)
        let display = scope(aerial, 2, linked: true)
        let index: [String: Any] = [
            "AllSpacesAndDisplays": global,
            "Displays": ["DISPLAY-A": display, "DISPLAY-B": global],
        ]
        precondition(WallpaperStore.choice(in: index, display: "display-a") == .aerial(id))
        precondition(WallpaperStore.choice(in: index, display: "DISPLAY-B") == .image(url))
        precondition(WallpaperStore.choice(in: index, display: "unknown") == .image(url))

        let spaceIndex: [String: Any] = [
            "AllSpacesAndDisplays": global,
            "Spaces": [
                "old": ["Default": scope(image, 3)],
                "recent": ["Displays": ["DISPLAY-A": scope(aerial, 4)]],
            ],
        ]
        precondition(WallpaperStore.choice(in: spaceIndex, display: "DISPLAY-A") == .aerial(id))
        precondition(WallpaperStore.choice(in: spaceIndex, display: "DISPLAY-B") == .image(url))

        let fileChoice: [String: Any] = [
            "Provider": "com.apple.wallpaper.choice.image",
            "Files": [["relative": url.absoluteString]],
        ]
        precondition(WallpaperStore.choice(in: ["SystemDefault": scope(fileChoice, 1)], display: nil) == .image(url))
        let folder = try choice("com.apple.wallpaper.choice.image", [
            "type": "imageFolder", "url": ["relative": url.absoluteString],
        ])
        precondition(WallpaperStore.choice(in: ["SystemDefault": scope(folder, 1)], display: nil) == .other("com.apple.wallpaper.choice.image"))
        let shuffled: [String: Any] = [
            "Type": "individual",
            "Desktop": ["Content": ["Choices": [image, image]]],
        ]
        precondition(WallpaperStore.choice(in: ["SystemDefault": shuffled], display: nil) == .other("com.apple.wallpaper.choice.image"))
        let idle: [String: Any] = ["Type": "idle", "Linked": ["Content": ["Choices": [aerial]]]]
        precondition(WallpaperStore.choice(in: ["AllSpacesAndDisplays": idle, "SystemDefault": global], display: nil) == .image(url))
        precondition(WallpaperStore.choice(in: [:], display: nil) == nil)
    }
}
