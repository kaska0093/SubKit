import Foundation

public struct SubscriptionInfo {
    public let profileWebPageURL: URL?
    public let profileTitle: String
    public let uploadBytes: Double
    public let downloadGB: Double
    public let totalBytes: Double
    public let expireTimestamp: Date?
    public let announce: String
    public let supportURL: URL?
    public let profileUpdateIntervalHours: Int?
    public let providerID: String
    public let pingType: String

    public init(
        profileWebPageURL: URL?,
        profileTitle: String,
        uploadBytes: Double,
        downloadGB: Double,
        totalBytes: Double,
        expireTimestamp: Date?,
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

func parseSubscriptionUserinfo(_ userinfo: String) -> (upload: Double, download: Double, total: Double, expire: Date?) {
    
    var Upload: Double = 0
    var download: Double = 0
    var Total: Double = 0
    var expire: Date? = nil
    
    
    let components = userinfo.components(separatedBy: "; ")
    var userInfoDict: [String: String] = [:]
    for component in components {
        let keyValue = component.components(separatedBy: "=")
        if keyValue.count == 2 {
            userInfoDict[keyValue[0]] = keyValue[1]
        }
    }
    
    // Upload (remains as is, in bytes)
    if let uploadStr = userInfoDict["upload"], let upload = Double(uploadStr) {
        print("Upload: \(upload) bytes")
        Upload = upload
        // → Upload: 0.0 bytes
    }
    
    // Download in GB
    if let downloadStr = userInfoDict["download"], let downloadBytes = Double(downloadStr) {
        let downloadGB = downloadBytes / (1024 * 1024 * 1024)
        print("Download: \(String(format: "%.2f", downloadGB)) GB")
        // → Download: 2919.99 GB
        download = downloadGB
    }
    
    // Total (0 means unlimited)
    if let totalStr = userInfoDict["total"], let total = Double(totalStr) {
        let remaining = (total == 0) ? "Unlimited" : "Limited to \(total) bytes"
        print("Remaining: \(remaining)")
        Total = total
        // → Remaining: Unlimited
    }
    
    // Expire date and remaining time
    if let expireStr = userInfoDict["expire"], let expireTimestamp = Double(expireStr) {
        let expireDate = Date(timeIntervalSince1970: expireTimestamp)
        
        // For simulation, assume current date is October 07, 2025 (in real code, use Date())
        let currentDate = Date(timeIntervalSince1970: 1760044800) // Unix timestamp for 2025-10-07 00:00:00 UTC
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        print("Expire date (UTC): \(dateFormatter.string(from: expireDate))")
        // → Expire date (UTC): 2026-11-16 17:49:04
        expire = expireDate
        
        let calendar = Calendar.current
        if let daysRemaining = calendar.dateComponents([.day], from: currentDate, to: expireDate).day {
            print("Days remaining: \(daysRemaining)")
            // → Days remaining: 405
        }
        
        let remainingInterval = expireDate.timeIntervalSince(currentDate)
        let remainingDays = Int(remainingInterval / 86400)
        let remainingHours = Int((remainingInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let remainingMinutes = Int((remainingInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let remainingSeconds = Int(remainingInterval.truncatingRemainder(dividingBy: 60))
        
        print("Remaining time: \(remainingDays) days, \(remainingHours):\(remainingMinutes):\(remainingSeconds)")
        // → Remaining time: 405 days, 17:49:4
    }
    return (Upload, download, Total, expire)
    
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
