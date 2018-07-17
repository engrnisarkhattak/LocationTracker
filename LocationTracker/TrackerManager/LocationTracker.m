//
//  LocationTracker.m
//  FeeKeeper
//
//  Created by Nasir on 13/07/2018.
//  Copyright © 2018 Nasir. All rights reserved.
//

#import "LocationTracker.h"

#define BACKGROUND_NOTIFICATION    @"backgroundNotification"
#define UPDATE_TIME    10
#define DELAY_TIME     60

@interface LocationTracker() <CLLocationManagerDelegate>{
    
    BOOL _startUpdat;
    BOOL startLocationInitialized;
    
    NSMutableArray *coordinatsArray;
}

@property (strong, nonatomic) UIApplication *app;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property  CLLocationCoordinate2D endPoint;
@property  CLLocationCoordinate2D midPoint;

@end

@implementation LocationTracker

+(LocationTracker *)sharedInstance{
    static LocationTracker *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[LocationTracker alloc] init];
    });
    
    return instance;
}

-(id)init{
    self = [super init];
    if (self) {
        // initialization
        [self initializeLocationManger];
    }
    return self;
}

#pragma mark - location

-(void)initializeLocationManger
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    [_locationManager requestAlwaysAuthorization];
    
    _app = [UIApplication sharedApplication];
    coordinatsArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}


//run background task
-(void)runBackgroundTask:(int)time{
    //check if application is in background mode
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        //create UIBackgroundTaskIdentifier and create tackground task, which starts after time
        __block UIBackgroundTaskIdentifier bgTask = [_app beginBackgroundTaskWithExpirationHandler:^{
            [self->_app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(startTrackingBg) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}


//starts with background task
-(void)startTrackingBg{
    
        
        //set default time
        int time = DELAY_TIME;
        //if locationManager is ON
        if (_startUpdat == YES ) {
            
            [self stopLocationUpdating];
        }else{
            
            [self startLocationUpdating];
            time = UPDATE_TIME;
        }
        
        if (_app.applicationState == UIApplicationStateBackground) {
            [self runBackgroundTask:time];
        }
        else{
            [self startUpdatingLocationWithInterval:time];
        }
}

-(void)startLocationUpdating
{
    _startUpdat = YES;
    [_locationManager startUpdatingLocation];
}

-(void)stopLocationUpdating
{
    _startUpdat = NO;
    [_locationManager stopUpdatingLocation];
}

-(void)startUpdatingLocationWithInterval:(int)time
{
    [NSTimer scheduledTimerWithTimeInterval:time repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self startTrackingBg];
    }];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    
    _endPoint = locations.lastObject.coordinate;
    [self initializeStartLocation];
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:_midPoint.latitude longitude:_midPoint.longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:locations.lastObject];
    
    // post notification if distance between two points is 10 meters
    if (distance > 10) {
        
        _midPoint = _endPoint;
        CLLocation *endLoc = [[CLLocation alloc] initWithLatitude:_endPoint.latitude longitude:_endPoint.longitude];
        
        [coordinatsArray addObject:endLoc];
        [self postBackgroundNotification];
    }
    
}

-(void)initializeStartLocation
{
    if (_endPoint.latitude > 0.00000 && !(startLocationInitialized)) {
        
        _startPoint = _endPoint;
        _midPoint = _endPoint;
        startLocationInitialized = YES;
        
        [self postBackgroundNotification];
    }
    
}


#pragma mark - Notification

-(void)applicationEnterBackground{
    
    if ( _app.applicationState == UIApplicationStateBackground) {
        NSLog(@"start backgroun tracking from appdelegate");
        
        [self startLocationUpdating];
        [self runBackgroundTask:DELAY_TIME];
    }
}

-(void)postBackgroundNotification
{
    NSDictionary *infoDict = @{@"coordinates":coordinatsArray};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BACKGROUND_NOTIFICATION object:self userInfo:infoDict];
}

@end
