import HTTP
import JSON

class NetworkDriver {
    enum Error: Swift.Error {
        case `internal`
        case apiKeyNotSet
        case appIDNotSet
        case requestError(value: String)
    }
    
    enum Endpoint: String {
        case sendNotification = "https://onesignal.com/api/v1/notifications"
    }
    
    var AUTH_HEADER: String {
        let apiKey = OneSignal.api_key!
        return "Basic \(apiKey)"
    }
    
    func send(_ notification: Notification, client: ClientFactoryProtocol) throws {
        guard OneSignal.api_key != nil else { throw Error.apiKeyNotSet }
        guard let appId = OneSignal.app_id else { throw Error.appIDNotSet }
        let endpoint = Endpoint.sendNotification
        
        var json = try JSON(node: [
            "app_id": appId,
            "contents": JSON(notification.message.makeNode(in: nil)),
            "include_player_ids": JSON(notification.users.makeNode(in: nil))
        ])
        
        if let title = notification.title {
            json["headings"] = JSON(try title.makeNode(in: nil))
        }
        
        
        if let subtitle = notification.subtitle {
            json["subtitle"] = JSON(try subtitle.makeNode(in: nil))
        }
        
        if let contentAvailable = notification.isContentAvailable {
            json["content_available"] = JSON(contentAvailable.makeNode(in: nil))
        }
        
        if let mutableContent = notification.isContentMutable {
            json["mutable_content"] = JSON(mutableContent.makeNode(in: nil))
        }

        let data = try json.makeBytes()
        let result = try client.post(
            endpoint.rawValue,
            query: [:],
            [
                "Content-Type": "application/json",
                "Authorization": AUTH_HEADER
            ],
            Body.data(data),
            through: []
        )
        
        print(result)
    }
}
