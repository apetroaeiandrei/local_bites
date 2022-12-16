import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let flavorChannel = FlutterMethodChannel(name: "flavor",
                                                 binaryMessenger: controller.binaryMessenger)
        flavorChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let flavor = Bundle.main.infoDictionary?["Flavor"] as? String
            result(flavor)
        })
        
        //Configure AppCheck for iOS debug builds
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
#endif
        
        GMSServices.provideAPIKey("YOUR_MAPS_API_KEY")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
