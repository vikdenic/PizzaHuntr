//
//  ViewController.m
//  Za_Hunter
//
//  Created by Vik Denic on 5/29/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "PizzaPlace.h"

@interface ViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray *pizzaPlacesArray;
@property (weak, nonatomic) IBOutlet UITableView *pizzaTableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc]init];
    self.myLocationManager.delegate = self;

    self.pizzaPlacesArray = [[NSMutableArray alloc]initWithCapacity:5];

    [self.myLocationManager startUpdatingLocation];

}

#pragma mark - Actions

//- (IBAction)locatePizzaButton:(id)sender {
//    [self.myLocationManager startUpdatingLocation];
//}

#pragma mark - Helpers

-(void)findPizzaPlace:(CLLocation *)location
{
    // Retreives data for a local search
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05,.05));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSArray *mapItems = response.mapItems;

        // Retrieves data for 5 closest Pizza Places
        for(int i = 0; i < 5; i++)
        {
            MKMapItem *mapItemWithData = [mapItems objectAtIndex:i];

            // Calculates how far user is from pizza place, in miles
            CLLocationDistance metersAway = [mapItemWithData.placemark.location distanceFromLocation:location];
            float milesDifference = metersAway / 1609.3430734;

            // Calculates average distance in coordinates from passed-in location
            float latDistance = fabsf( location.coordinate.latitude - mapItemWithData.placemark.location.coordinate.latitude );
            float longDistance = fabsf( location.coordinate.longitude - mapItemWithData.placemark.location.coordinate.longitude );
            float hypotenuseLength = latDistance + longDistance;

            // Creates new PizzaPlace reference
            PizzaPlace *pizzaPlace = [[PizzaPlace alloc]init];

            // Sets milesDistance property for PizzaPlace reference
            pizzaPlace.milesDifference = milesDifference;

            // Sets coordinateDifference property for PizzaPlace reference
            pizzaPlace.coordinatesDifference = hypotenuseLength;

            // Sets MKMapItem property for PizzaPlace reference
            pizzaPlace.mapItem = mapItemWithData;

            // Adds PizzaPlace reference to mutable array
            [self.pizzaPlacesArray addObject:pizzaPlace];
        }

        // Orders the array of PizzaPlaces by their milesAway property
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"coordinatesDifference" ascending:YES];
        NSArray *sortedArray = [self.pizzaPlacesArray sortedArrayUsingDescriptors:@[sortDescriptor]];

//        for(PizzaPlace *pizzaPlace in self.pizzaPlacesArray)
//        {
//            NSLog(@"%@ is %f away",pizzaPlace.mapItem.name, pizzaPlace.milesDifference);
//        }
        [self.pizzaTableView reloadData];
    }];
}

#pragma mark - Delegates

// TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pizzaPlacesArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PizzaPlace *pizzaRef = [self.pizzaPlacesArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PizzaCellID"];
    cell.textLabel.text = pizzaRef.mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fm away",pizzaRef.milesDifference];

    return cell;
}

//CLLocationManager
-(void)reverseGeoCode:(CLLocation *)location
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *zaMessage = [NSString stringWithFormat:@"Eat Pizza at:\n%@ %@ \n%@",
                               placemark.subThoroughfare,
                               placemark.thoroughfare,
                               placemark.locality];
//        NSLog(@"%@",zaMessage);
        [self findPizzaPlace:location];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for(CLLocation *location in locations)
    {

        if (location.verticalAccuracy <1000 && location.horizontalAccuracy < 1000)
        {
            [self reverseGeoCode: location];
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

@end