import Foundation

enum WallpaperStore {
    enum Choice: Equatable {
        case image(URL)
        case aerial(String)
        case other(String)
    }

    static func choice(in index: [String: Any], display: String?) -> Choice? {
        func entry(_ value: Any?) -> [String: Any]? {
            guard let scope = value as? [String: Any],
                scope["Type"] as? String != "idle"
            else { return nil }
            let key = scope["Type"] as? String == "linked" ? "Linked" : "Desktop"
            guard let selected = (scope[key] ?? scope["Linked"]) as? [String: Any],
                let content = selected["Content"] as? [String: Any],
                let choices = content["Choices"] as? [[String: Any]],
                !choices.isEmpty
            else { return nil }
            return selected
        }
        func displayEntry(_ value: Any?) -> Any? {
            guard let display, let displays = value as? [String: Any] else { return nil }
            return displays.first { $0.key.caseInsensitiveCompare(display) == .orderedSame }?.value
        }
        var candidates: [[String: Any]] = []
        if let spaces = index["Spaces"] as? [String: Any] {
            for value in spaces.values {
                guard let space = value as? [String: Any] else { continue }
                if let selected = entry(displayEntry(space["Displays"]))
                    ?? entry(space["Default"])
                {
                    candidates.append(selected)
                }
            }
        }
        for value in [
            displayEntry(index["Displays"]), index["AllSpacesAndDisplays"],
            index["SystemDefault"],
        ] {
            if let selected = entry(value) { candidates.append(selected) }
        }
        // The store does not expose the active Space; LastUse is its best public hint.
        let latest = candidates.reduce(nil as [String: Any]?) { current, candidate in
            guard let current else { return candidate }
            return (candidate["LastUse"] as? Date ?? .distantPast)
                > (current["LastUse"] as? Date ?? .distantPast) ? candidate : current
        }
        guard let content = latest?["Content"] as? [String: Any],
            let choices = content["Choices"] as? [[String: Any]],
            let selected = choices.first,
            let provider = selected["Provider"] as? String
        else { return nil }
        guard choices.count == 1 else { return .other(provider) }
        let configuration = (selected["Configuration"] as? Data).flatMap {
            (try? PropertyListSerialization.propertyList(from: $0, format: nil)) as? [String: Any]
        }
        if provider == "com.apple.wallpaper.choice.aerials",
            let id = configuration?["assetID"] as? String
        {
            return .aerial(id)
        }
        if provider == "com.apple.wallpaper.choice.image"
            || provider == "com.apple.wallpaper.choice.dynamic"
        {
            let type = configuration?["type"] as? String
            if type == "imageFile" || type == "systemDesktopPicture" {
                if let relative = (configuration?["url"] as? [String: Any])?["relative"] as? String,
                    let url = URL(string: relative), url.isFileURL
                {
                    return .image(url)
                }
            } else if type == nil,
                let files = selected["Files"] as? [[String: Any]],
                files.count == 1, let relative = files.first?["relative"] as? String,
                let url = URL(string: relative), url.isFileURL
            {
                return .image(url)
            }
        }
        return .other(provider)
    }
}
