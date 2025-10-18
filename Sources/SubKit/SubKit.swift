import Foundation

public struct SubscriptionInfo {
    public let profileWebPageURL: URL?
    public let profileTitle: String
    public let uploadBytes: Int64
    public let downloadGB: Double
    public let totalBytes: Int64
    public let expireTimestamp: TimeInterval?
    public let announce: String
    public let supportURL: URL?
    public let profileUpdateIntervalHours: Int?
    public let providerID: String
    public let pingType: String

    public init(
        profileWebPageURL: URL?,
        profileTitle: String,
        uploadBytes: Int64,
        downloadGB: Double,
        totalBytes: Int64,
        expireTimestamp: TimeInterval?,
        announce: String,
        supportURL: URL?,
        profileUpdateIntervalHours: Int?,
        providerID: String,
        pingType: String
    ) {
        self.profileWebPageURL = profileWebPageURL
        self.profileTitle = profileTitle
        self.uploadBytes = uploadBytes
        self.downloadGB = downloadGB
        self.totalBytes = totalBytes
        self.expireTimestamp = expireTimestamp
        self.announce = announce
        self.supportURL = supportURL
        self.profileUpdateIntervalHours = profileUpdateIntervalHours
        self.providerID = providerID
        self.pingType = pingType
    }
}

// MARK: - Helpers

func decodeIfBase64(_ string: String) -> String {
    guard !string.isEmpty,
          let data = Data(base64Encoded: string) else {
        return string
    }
    return String(data: data, encoding: .utf8) ?? string
}

func parseSubscriptionUserinfo(_ userinfo: String) -> (upload: Int64, download: Double, total: Int64, expire: TimeInterval?) {
    var upload: Int64 = 0
    var download: Double = 0.0
    var total: Int64 = 0
    var expire: TimeInterval?

    let components = userinfo.components(separatedBy: ";")
    for component in components {
        let parts = component.trimmingCharacters(in: .whitespaces).components(separatedBy: "=")
        guard parts.count == 2 else { continue }
        let key = parts[0].lowercased()
        let value = parts[1]

        switch key {
        case "upload":
            upload = Int64(value) ?? 0
        case "download":
            download = Double(value) ?? 0.0
        case "total":
            total = Int64(value) ?? 0
        case "expire":
            expire = TimeInterval(value) ?? nil
        default:
            break
        }
    }

    // Конвертируем байты в гигабайты для downloadGB
    download = download / (1024 * 1024 * 1024)

    return (upload, download, total, expire)
}

// MARK: - Main Parser

public func parseHeaders(from response: HTTPURLResponse) -> SubscriptionInfo {
    let headers = response.allHeaderFields

    let profileWebPageURL = (headers["profile-web-page-url"] as? String).flatMap(URL.init(string:))
    let profileTitle = decodeIfBase64(headers["profile-title"] as? String ?? "")
    
    let userinfo = headers["subscription-userinfo"] as? String ?? ""
    let (upload, download, total, expire) = parseSubscriptionUserinfo(userinfo)
    
    let announce = decodeIfBase64(headers["announce"] as? String ?? "")
    let supportURL = (headers["support-url"] as? String).flatMap(URL.init(string:))
    let profileUpdateIntervalHours = (headers["profile-update-interval"] as? String).flatMap(Int.init)
    let providerID = headers["providerid"] as? String ?? ""
    let pingType = headers["ping-type"] as? String ?? ""

    return SubscriptionInfo(
        profileWebPageURL: profileWebPageURL,
        profileTitle: profileTitle,
        uploadBytes: upload,
        downloadGB: download,
        totalBytes: total,
        expireTimestamp: expire,
        announce: announce,
        supportURL: supportURL,
        profileUpdateIntervalHours: profileUpdateIntervalHours,
        providerID: providerID,
        pingType: pingType
    )
}
