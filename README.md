# LocationTracker

LocationTracker iOS application helps you to track your location even if your application goes to background.

HOW TO USE:

Integrate GooglePlaces and GoogleMaps in your application. If you are new to GoogleMaps you can visit:
https://developers.google.com/maps/documentation/ios-sdk/start
After successfull integration of GoogleMaps and GooglePlaces place these two lines in your application delegate .m file 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:"YOUR API KEY"];
    [GMSPlacesClient provideAPIKey:"YOUR APKI KEY"];
    
    return YES;
}

GO to application Targets->Capabilities->SwitchOn background Mode-> check Location Updats
Add following two keys in application info.plist with description:

Privacy - Location When In Use Usage Description
Privacy - Location Always and When In Use Usage Description

Manually drag and drop the LocationTracker.h and LocationTracker.m files in your project
You can use the following two methods to start and stop updating location in your desiredViewController:

- (IBAction)startBtn_clicked:(id)sender {
    
    [[LocationTracker sharedInstance] startUpdatingLocationWithInterval:1];
}

- (IBAction)stopBtn_clicked:(id)sender {
    
    [[LocationTracker sharedInstance] stopLocationUpdating];
    
}

