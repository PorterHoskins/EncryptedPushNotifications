import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        
        OneSignal.app_id = "de2757f4-3281-4b5e-80bd-cf0113f186a6"
        OneSignal.api_key = "MDdmODM1OWEtZDU2Ny00ZTBlLWI4NjEtMGZlZWQ2ZWExMTAx"
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
    }
}
