//
//  PizzaPlace.h
//  Za_Hunter
//
//  Created by Vik Denic on 5/29/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PizzaPlace : NSObject

@property MKMapItem *mapItem;
@property float milesDifference;
@property float coordinatesDifference;

@end
