//
//  LocationVC.m
//  LocationTracker
//
//  Created by Nasir on 17/07/2018.
//  Copyright © 2018 Nasir. All rights reserved.
//

#import "LocationVC.h"
#import "LocationTracker.h"
#import <GoogleMaps/GoogleMaps.h>

#define BACKGROUND_NOTIFICATION    @"backgroundNotification"

@interface LocationVC (){
    
    GMSMapView *mapView;
    CLLocationCoordinate2D startPoint;
    
    BOOL isMapViewInitialized;
}

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"LOCATION";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self buildMapView];
        
    });
    
}

-(void)buildMapView
{
    [self.view layoutIfNeeded];
    mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    mapView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:mapView];
    
    [self.view sendSubviewToBack:mapView];
}




#pragma mark - actions

- (IBAction)startBtn_clicked:(id)sender {
    
    [[LocationTracker sharedInstance] startUpdatingLocationWithInterval:1];
}

- (IBAction)stopBtn_clicked:(id)sender {
    
    [[LocationTracker sharedInstance] stopLocationUpdating];
    
}


#pragma mark - location Manager

-(void)loadMapViewWithStartLocation
{
    if ([[LocationTracker sharedInstance] startPoint].latitude > 0.00000 && !(isMapViewInitialized)) {
        
        startPoint = [[LocationTracker sharedInstance] startPoint];
        isMapViewInitialized = YES;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:startPoint.latitude longitude:startPoint.longitude zoom:15.0];
        mapView.camera = camera;
        
        [self addMarkerToStartLocation:startPoint];
    }
    
}

-(void)addMarkerToStartLocation:(CLLocationCoordinate2D)point
{
    GMSMarker *marker = [GMSMarker markerWithPosition:point];
    marker.map = mapView;
}

-(void)drawRouteOn:(NSArray *)locArray
{
    GMSPolyline *polyline = nil;
    if ([locArray count] > 0) {
        
        GMSMutablePath *path = [GMSMutablePath path];
        for (CLLocation *tempLoc in locArray) {
            
            [path addCoordinate:tempLoc.coordinate];
        }
        
        polyline = [GMSPolyline polylineWithPath:path];
    }
    
    if(polyline){
        
        [mapView clear];
        [self addMarkerToStartLocation:startPoint];
        
        polyline.strokeWidth = 2.0;
        polyline.strokeColor = [UIColor redColor];
        
        polyline.map = self->mapView;
    }
}

#pragma mark - notification


-(void)applicationEnterBackground:(NSNotification *)notification{
    
    if ([[notification name] isEqualToString:BACKGROUND_NOTIFICATION]) {
        
        NSDictionary *locationInfo = notification.userInfo;
        NSArray *locations = [locationInfo objectForKey:@"coordinates"];
        [self loadMapViewWithStartLocation];
        [self drawRouteOn:locations];
        
    }
}



#pragma mark - viewController Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:BACKGROUND_NOTIFICATION object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BACKGROUND_NOTIFICATION object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
