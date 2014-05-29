//
//  ViewController.m
//  ZaHunter
//
//  Created by David Warner on 5/29/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "PizzaPlace.h"

@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSArray *pizzaLocations;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property CLLocation *userLocation;
@property NSMutableArray *sortedArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc] init];
    self.myLocationManager.delegate = self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self.myLocationManager stopUpdatingLocation];
            [self findPizzaNear:location];
            self.userLocation = location;
            break;
        }
    }
}

-(void)findPizzaNear:(CLLocation *)location
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.3, .3));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.pizzaLocations = response.mapItems;

        NSMutableArray *arrayOfPizzaLocationMapItems = [[NSMutableArray alloc]init];

        for (MKMapItem *eachPizzaPlace in response.mapItems) {
            PizzaPlace *pizzaPlace = [[PizzaPlace alloc] init];
            pizzaPlace.distance = [self.userLocation distanceFromLocation:eachPizzaPlace.placemark.location];
            pizzaPlace.name = eachPizzaPlace.name;
            [arrayOfPizzaLocationMapItems addObject:pizzaPlace];
        }

        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        NSArray *tempArray = [arrayOfPizzaLocationMapItems sortedArrayUsingDescriptors:@[descriptor]];

        self.sortedArray = [[NSMutableArray alloc] init];
        int x = 0;
        for (PizzaPlace *place in tempArray) {
            if (x<4) {
            [self.sortedArray addObject:place];
            x++;
            }
        }
        [self.myTableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    PizzaPlace *pizzaPlace = [self.sortedArray objectAtIndex:indexPath.row];
    cell.textLabel.text = pizzaPlace.name;

    CGFloat distanceMtrs = pizzaPlace.distance;
    CGFloat distanceMiles = distanceMtrs * .000621371192;
    NSString *distanceString = [NSString stringWithFormat:@"%.2f miles", distanceMiles];
    cell.detailTextLabel.text = distanceString;

    return cell;
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (IBAction)onFindPizzaPressed:(id)sender
{
    [self.myLocationManager startUpdatingLocation];
}


@end
