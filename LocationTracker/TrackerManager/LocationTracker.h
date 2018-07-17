//
//  LocationTracker.h
//  FeeKeeper
//
//  Created by Nasir on 13/07/2018.
//  Copyright © 2018 Nasir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface LocationTracker : NSObject{
    
}

@property  CLLocationCoordinate2D startPoint;

+(LocationTracker *)sharedInstance;

-(void)stopLocationUpdating;
-(void)startUpdatingLocationWithInterval:(int)time;

@end
