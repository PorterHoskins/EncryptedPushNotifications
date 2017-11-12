import HTTP

public class OneSignal {
    private init() {}
    
    public static var api_key: String?
    public static var app_id: String?
    public static let instance = OneSignal()
    
    let driver = NetworkDriver()
    
    public func send(notification: Notification, client: ClientFactoryProtocol) throws {
        try driver.send(notification, client: client)
    }
}
